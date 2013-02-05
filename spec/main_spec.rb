require 'spec_helper'

describe 'List Service' do
	before do
		@user1 = User.create(:username => 'test_user1')

		@list1 = List.create(:name => 'test_list1', :title => 'test_list1')
		@item1 = @list1.items.create(:name => 'test_item1', :deleted => false, :needed=> true)
		@item2 = @list1.items.create(:name => 'test_item2', :deleted => false, :needed=> false)
		@item3 = @list1.items.create(:name => 'test_item3', :deleted => true,  :needed=> true)
		@item4 = @list1.items.create(:name => 'test_item4', :deleted => true,  :needed=> false)

		@list2 = List.create(:name => 'test_list2')

		@list3 = List.new(:name => 'invalid_list1')
		@item5 = Item.new(:name => 'invalid_item1')
	end

	describe 'get /lists/:list' do
		it 'renders a list with items' do
			get "/lists/#{@list1.name}"
			last_response.status.should == 200
			last_response.body.should == @list1.to_json
		end

		it 'renders an empty list' do
			get "/lists/#{@list2.name}"
			last_response.status.should == 200
			last_response.body.should == @list2.to_json
		end

		it 'returns 404 on non-existant lists' do
			get "/lists/#{@list3.name}"
			last_response.status.should == 404
			last_response.body.should be_empty
		end
	end

	describe 'get lists/:list/items' do
		it 'renders a list of items' do
			get "/lists/#{@list1.name}/items"
			last_response.status.should == 200
			last_response.body.should == @list1.items.to_json
		end

		it 'renders an empty list of items' do
			get "/lists/#{@list2.name}/items"
			last_response.status.should == 200
			last_response.body.should == @list2.items.to_json
		end

		it 'returns 404 on non-existant lists' do
			get "/lists/#{@list3.name}/items"
			last_response.status.should == 404
			last_response.body.should be_empty
		end
	end

	describe 'get lists/:list/items/:item' do
		it 'renders an item' do
			get "/lists/#{@item1.list.name}/items/#{@item1.name}"
			last_response.status.should == 200
			last_response.body.should == @item1.to_json
		end
		it 'returns 404 on non-existant lists' do
			get "/lists/#{@list3.name}/items/#{@item1.name}"
			last_response.status.should == 404
			last_response.body.should be_empty
		end
		it 'returns 404 on non-existant items' do
			get "/lists/#{@list1.name}/items/#{@item5.name}"
			last_response.status.should == 404
			last_response.body.should be_empty
		end
	end

	describe 'put lists/:list/items/:item' do
		it 'should create a new needed item and add it to an existing list' do
			put "/lists/#{@list1.name}/items/new_item1", :needed => true
			last_response.status.should == 200
			items = @list1.items.where(:name => 'new_item1')
			items.count.should == 1
			item = items[0]
			item.deleted.should == false
			item.needed.should == true
		end

		it 'should create a new unneeded item and add it to an existing list' do
			put "/lists/#{@list1.name}/items/new_item1", :needed => false
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
			list = List.find_by_name('new_list1')
			list.should_not == nil
			list.title.should == ''
		end

		it 'should create a new list with a title' do
			put '/lists/new_list1/items/new_item1', :title => 'New List'
			last_response.status.should == 200
			list = List.find_by_name('new_list1')
			list.should_not == nil
			list.title.should == 'New List'
		end

		it 'should update a list title' do
			put "/lists/#{@list1.name}/items/new_item1", :title => 'New Title'
			last_response.status.should == 200
			@list1.reload
			@list1.title.should == 'New Title'
		end

		it 'should update a list and not update the title' do
			put "/lists/#{@list1.name}/items/new_item1"
			last_response.status.should == 200
			old_title = @list1.title
			@list1.reload
			@list1.title.should == old_title
		end

		it 'should create a new list and a new needed item' do
			put '/lists/new_list1/items/new_item1', :title => 'New List', :needed => true
			last_response.status.should == 200
			list = List.find_by_name('new_list1')
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
			list = List.find_by_name('new_list1')
			list.should_not == nil
			items = list.items.where(:name => 'new_item1')
			items.count.should == 1
			item = items[0]
			item.deleted.should == false
			item.needed.should == false
		end

		it 'should mark a needed item needed' do
			put "/lists/#{@item1.list.name}/items/#{@item1.name}", :needed => true
			last_response.status.should == 200
			@item1.reload
			@item1.deleted.should == false
			@item1.needed.should == true
		end

		it 'should mark an unneeded item needed' do
			put "/lists/#{@item2.list.name}/items/#{@item2.name}", :needed => true
			last_response.status.should == 200
			@item2.reload
			@item2.deleted.should == false
			@item2.needed.should == true
		end

		it 'should mark a needed item unneeded' do
			put "/lists/#{@item1.list.name}/items/#{@item1.name}", :needed => false
			last_response.status.should == 200
			@item1.reload
			@item1.deleted.should == false
			@item1.needed.should == false
		end

		it 'should mark an unneeded item unneeded' do
			put "/lists/#{@item2.list.name}/items/#{@item2.name}", :needed => false
			last_response.status.should == 200
			@item2.reload
			@item2.deleted.should == false
			@item2.needed.should == false
		end

		it 'should undelete a deleted item and mark it unneeded' do
			put "/lists/#{@item3.list.name}/items/#{@item3.name}", :needed => false
			last_response.status.should == 200
			@item3.reload
			@item3.deleted.should == false
			@item3.needed.should == false
		end

		it 'should undelete a deleted item and mark it needed' do
			put "/lists/#{@item4.list.name}/items/#{@item4.name}", :needed => true
			last_response.status.should == 200
			@item4.reload
			@item4.deleted.should == false
			@item4.needed.should == true
		end
	end

	describe 'delete lists/:list/items/:item' do
		it 'should delete an item' do
			delete "/lists/#{@item1.list.name}/items/#{@item1.name}"
			last_response.status.should == 200
			@item1.reload
			@item1.deleted.should == true
		end

		it 'should not delete a non-existant item' do
			delete "/lists/#{@list1.name}/items/#{@item5.name}"
			last_response.status.should == 404
			last_response.body.should be_empty
		end

		it 'should not delete an item from a non-existant list' do
			delete "/lists/#{@list3.name}/items/#{@item1.name}"
			last_response.status.should == 404
			last_response.body.should be_empty
		end
	end
=======
	end

	it 'puts the lotion in the basket' do
		get '/'
		last_response.status.should == 200
		last_response.body.should == 'Hi'
	end

	it 'should create a new needed item and add it to an existing list' do
		post "/lists/#{@list1.id}/items", :name => 'new_item1', :needed => true
		last_response.status.should == 200
		items = List.find_by_name('test_list1').items.where(:name => 'new_item1')
		items.count.should == 1
		item = items[0]
		item.deleted.should == false
		item.needed.should == true
	end

	it 'should create a new unneeded item and add it to an existing list' do
		post "/lists/#{@list1.id}/items", :name => 'new_item1', :needed => false
		last_response.status.should == 200
		items = List.find_by_name('test_list1').items.where(:name => 'new_item1')
		items.count.should == 1
		item = items[0]
		item.deleted.should == false
		item.needed.should == false
	end

	it 'should create a new list and a new needed item' do
		post '/lists', :title => 'new_list1'
		last_response.status.should == 200
		list = JSON last_response.body

		post "/lists/#{list['id']}/items", :name => 'new_item1', :needed => true
		last_response.status.should == 200

		list = List.find_by_name('new_list1')
		list.should_not == nil
		items = list.items.where(:name => 'new_item1')
		items.count.should == 1
		item = items[0]
		item.deleted.should == false
		item.needed.should == true
	end

	it 'should create a new list and a new unneeded item' do
		post '/lists', :title => 'new_list1'
		last_response.status.should == 200
		list = JSON last_response.body

		post "/lists/#{list['id']}/items", :name => 'new_item1', :needed => false
		last_response.status.should == 200

		last_response.status.should == 200
		list = List.find_by_name('new_list1')
		list.should_not == nil
		items = list.items.where(:name => 'new_item1')
		items.count.should == 1
		item = items[0]
		item.deleted.should == false
		item.needed.should == false
	end

	it 'should mark a needed item needed' do
		put "/lists/#{@list1.id}/items/#{@item1.id}", :needed => true
		last_response.status.should == 200
		item = List.find_by_name('test_list1').items.where(:name => 'test_item1').first
		item.deleted.should == false
		item.needed.should == true
	end

	it 'should mark an unneeded item needed' do
		put "/lists/#{@list1.id}/items/#{@item2.id}", :needed => true
		last_response.status.should == 200
		item = List.find_by_name('test_list1').items.where(:name => 'test_item2').first
		item.deleted.should == false
		item.needed.should == true
	end

	it 'should mark a needed item unneeded' do
		put "/lists/#{@list1.id}/items/#{@item1.id}", :needed => false
		last_response.status.should == 200
		item = List.find_by_name('test_list1').items.where(:name => 'test_item1').first
		item.deleted.should == false
		item.needed.should == false
	end

	it 'should mark an unneeded item unneeded' do
		put "/lists/#{@list1.id}/items/#{@item2.id}", :needed => false
		last_response.status.should == 200
		item = List.find_by_name('test_list1').items.where(:name => 'test_item2').first
		item.deleted.should == false
		item.needed.should == false
	end

	it 'should undelete a deleted item and mark it unneeded' do
		put "/lists/#{@list1.id}/items/#{@item3.id}", :needed => false
		last_response.status.should == 200
		item = List.find_by_name('test_list1').items.where(:name => 'test_item3').first
		item.deleted.should == false
		item.needed.should == false
	end

	it 'should undelete a deleted item and mark it needed' do
		put "/lists/#{@list1.id}/items/#{@item4.id}", :needed => true
		last_response.status.should == 200
		item = List.find_by_name('test_list1').items.where(:name => 'test_item4').first
		item.deleted.should == false
		item.needed.should == true
	end

	it 'should delete an item' do
		delete "/lists/#{@list1.id}/items/#{@item1.id}"
		last_response.status.should == 200
		item = List.find_by_name('test_list1').items.where(:name => 'test_item1').first
		item.deleted.should == true
	end
