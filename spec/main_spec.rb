require 'spec_helper'

describe 'List Service' do
	before do
		@user1 = User.create(:id => 'test_user1', :wp_notify_url => 'wp.example.com', :android_notify_url => 'android.example.com')
		@user2 = User.create(:id => 'test_user2')

		@list1 = List.create(:id => 'test_list1', :title => 'Test List 1')
		@list1.users << [ @user1, @user2 ]

		@item1 = @list1.items.create(:name => 'test_item1', :deleted => false, :needed=> true)
		@item2 = @list1.items.create(:name => 'test_item2', :deleted => false, :needed=> false)
		@item3 = @list1.items.create(:name => 'test_item3', :deleted => true,  :needed=> true)
		@item4 = @list1.items.create(:name => 'test_item4', :deleted => true,  :needed=> false)

		@list2 = List.create(:id => 'test_list2')

		@user3 = User.new(:id => 'invalid_user1')
		@list3 = List.new(:id => 'invalid_list1')
		@item5 = Item.new(:name => 'invalid_item1')
	end

	describe 'get /lists/:list_id' do
		it 'renders a list with items' do
			get "/lists/#{@list1.id}"
			last_response.status.should == 200
			last_response.body.should == @list1.to_json
		end

		it 'renders an empty list' do
			get "/lists/#{@list2.id}"
			last_response.status.should == 200
			last_response.body.should == @list2.to_json
		end

		it 'returns 404 on non-existant lists' do
			get "/lists/#{@list3.id}"
			last_response.status.should == 404
			last_response.body.should be_empty
		end
	end

	describe 'get /lists/:list_id/items' do
		it 'renders a list of items' do
			get "/lists/#{@list1.id}/items"
			last_response.status.should == 200
			last_response.body.should == @list1.items.to_json
		end

		it 'renders an empty list of items' do
			get "/lists/#{@list2.id}/items"
			last_response.status.should == 200
			last_response.body.should == @list2.items.to_json
		end

		it 'returns 404 on non-existant lists' do
			get "/lists/#{@list3.id}/items"
			last_response.status.should == 404
			last_response.body.should be_empty
		end
	end

	describe 'get /lists/:list_id/items/:item' do
		it 'renders an item' do
			get "/lists/#{@item1.list.id}/items/#{@item1.name}"
			last_response.status.should == 200
			last_response.body.should == @item1.to_json
		end
		it 'returns 404 on non-existant lists' do
			get "/lists/#{@list3.id}/items/#{@item1.name}"
			last_response.status.should == 404
			last_response.body.should be_empty
		end
		it 'returns 404 on non-existant items' do
			get "/lists/#{@list1.id}/items/#{@item5.name}"
			last_response.status.should == 404
			last_response.body.should be_empty
		end
	end

	describe 'put /lists/:list_id/items/:item' do
		it 'should create a new needed item and add it to an existing list' do
			put "/lists/#{@list1.id}/items/new_item1", :needed => true
			last_response.status.should == 200
			items = @list1.items.where(:name => 'new_item1')
			items.count.should == 1
			item = items[0]
			item.deleted.should == false
			item.needed.should == true
		end

		it 'should create a new unneeded item and add it to an existing list' do
			put "/lists/#{@list1.id}/items/new_item1", :needed => false
			last_response.status.should == 200
			items = @list1.items.where(:name => 'new_item1')
			items.count.should == 1
			item = items[0]
			item.deleted.should == false
			item.needed.should == false
		end

		it 'should create a new list without a title' do
			put '/lists/new_list1/items/new_item1'
			last_response.status.should == 200
			list = List.find_by_id('new_list1')
			list.should_not == nil
			list.title.should == ''
		end

		it 'should create a new list with a title' do
			put '/lists/new_list1/items/new_item1', :title => 'New List'
			last_response.status.should == 200
			list = List.find_by_id('new_list1')
			list.should_not == nil
			list.title.should == 'New List'
		end

		it 'should update a list title' do
			put "/lists/#{@list1.id}/items/new_item1", :title => 'New Title'
			last_response.status.should == 200
			@list1.reload
			@list1.title.should == 'New Title'
		end

		it 'should update a list and not update the title' do
			put "/lists/#{@list1.id}/items/new_item1"
			last_response.status.should == 200
			old_title = @list1.title
			@list1.reload
			@list1.title.should == old_title
		end

		it 'should create a new list and a new needed item' do
			put '/lists/new_list1/items/new_item1', :title => 'New List', :needed => true
			last_response.status.should == 200
			list = List.find_by_id('new_list1')
			list.should_not == nil
			items = list.items.where(:name => 'new_item1')
			items.count.should == 1
			item = items[0]
			item.deleted.should == false
			item.needed.should == true
		end

		it 'should create a new list and a new unneeded item' do
			put '/lists/new_list1/items/new_item1', :needed => false
			last_response.status.should == 200
			list = List.find_by_id('new_list1')
			list.should_not == nil
			items = list.items.where(:name => 'new_item1')
			items.count.should == 1
			item = items[0]
			item.deleted.should == false
			item.needed.should == false
		end

		it 'should mark a needed item needed' do
			put "/lists/#{@item1.list.id}/items/#{@item1.name}", :needed => true
			last_response.status.should == 200
			@item1.reload
			@item1.deleted.should == false
			@item1.needed.should == true
		end

		it 'should mark an unneeded item needed' do
			put "/lists/#{@item2.list.id}/items/#{@item2.name}", :needed => true
			last_response.status.should == 200
			@item2.reload
			@item2.deleted.should == false
			@item2.needed.should == true
		end

		it 'should mark a needed item unneeded' do
			put "/lists/#{@item1.list.id}/items/#{@item1.name}", :needed => false
			last_response.status.should == 200
			@item1.reload
			@item1.deleted.should == false
			@item1.needed.should == false
		end

		it 'should mark an unneeded item unneeded' do
			put "/lists/#{@item2.list.id}/items/#{@item2.name}", :needed => false
			last_response.status.should == 200
			@item2.reload
			@item2.deleted.should == false
			@item2.needed.should == false
		end

		it 'should undelete a deleted item and mark it unneeded' do
			put "/lists/#{@item3.list.id}/items/#{@item3.name}", :needed => false
			last_response.status.should == 200
			@item3.reload
			@item3.deleted.should == false
			@item3.needed.should == false
		end

		it 'should undelete a deleted item and mark it needed' do
			put "/lists/#{@item4.list.id}/items/#{@item4.name}", :needed => true
			last_response.status.should == 200
			@item4.reload
			@item4.deleted.should == false
			@item4.needed.should == true
		end
	end

	describe 'delete /lists/:list_id/items/:item' do
		it 'should delete an item' do
			delete "/lists/#{@item1.list.id}/items/#{@item1.name}"
			last_response.status.should == 200
			@item1.reload
			@item1.deleted.should == true
		end

		it 'should not delete a non-existant item' do
			delete "/lists/#{@list1.id}/items/#{@item5.name}"
			last_response.status.should == 404
			last_response.body.should be_empty
		end

		it 'should not delete an item from a non-existant list' do
			delete "/lists/#{@list3.id}/items/#{@item1.name}"
			last_response.status.should == 404
			last_response.body.should be_empty
		end
	end

	describe 'put /users/:user_id' do
		it 'should not create a new user without any notify URLs' do
			put '/users/new_user1'
			last_response.status.should == 200
			last_response.body.should be_empty
			user = User.find_by_id('new_user1')
			user.should == nil
		end

		it 'should create a new user with at least one notify URL' do
			put '/users/new_user1', :wp_notify_url => 'wp.example.com'
			last_response.status.should == 200
			last_response.body.should be_empty
			user = User.find_by_id('new_user1')
			user.should_not == nil
			user.id.should == 'new_user1'
			user.wp_notify_url.should == 'wp.example.com'
			user.ios_notify_url.should be_empty
			user.android_notify_url.should be_empty
		end

		it 'should update an existing user' do
			put "/users/#{@user1.id}", :wp_notify_url => ''
			last_response.status.should == 200
			last_response.body.should be_empty
			old_ios_notify_url = @user1.ios_notify_url
			old_android_notify_url = @user1.android_notify_url
			@user1.reload
			@user1.wp_notify_url.should be_empty
			@user1.ios_notify_url.should == old_ios_notify_url
			@user1.android_notify_url.should == old_android_notify_url
		end
	end

	describe 'put /users/:user_id/subscribe' do
		it 'should subscribe an existing user to an existing list' do
			put "/users/#{@user1.id}/subscribe", :list_id => @list2.id
			last_response.status.should == 200
			last_response.body.should be_empty
			@user1.reload
			@list2.reload
			@user1.lists.include?(@list2).should == true
			@list2.users.include?(@user1).should == true
		end
		it 'should not subscribe an existing user to an invalid list' do
			put "/users/#{@user1.id}/subscribe", :list_id => @list3.id
			last_response.status.should == 404
			last_response.body.should be_empty
			@user1.reload
			@user1.lists.include?(@list3).should == false
		end
		it 'should not subscribe an invalid user to an existing list' do
			put "/users/#{@user3.id}/subscribe", :list_id => @list1.id
			last_response.status.should == 404
			last_response.body.should be_empty
			@list1.reload
			@list1.users.include?(@user3).should == false
		end
	end

	describe 'put /users/:user_id/unsubscribe' do
		it 'should unsubscribe an existing user to an existing list' do
			put "/users/#{@user1.id}/unsubscribe", :list_id => @list1.id
			last_response.status.should == 200
			last_response.body.should be_empty
			@user1.reload
			@list1.reload
			@user1.lists.include?(@list1).should == false
			@list1.users.include?(@user1).should == false
		end
		it 'should not unsubscribe an existing user to an invalid list' do
			put "/users/#{@user1.id}/unsubscribe", :list_id => @list3.id
			last_response.status.should == 404
			last_response.body.should be_empty
			@user1.reload
			@user1.lists.include?(@list3).should == false
		end
		it 'should not unsubscribe an invalid user to an existing list' do
			put "/users/#{@user3.id}/unsubscribe", :list_id => @list1.id
			last_response.status.should == 404
			last_response.body.should be_empty
			@list1.reload
			@list1.users.include?(@user3).should == false
		end
	end
end
