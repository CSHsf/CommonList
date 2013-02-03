require 'spec_helper'

describe 'List Service' do
	before :each do
		@user1 = User.create(:username => 'test_user1')

		@list1 = List.create(:name => 'test_list1')
		@item1 = @list1.items.create(:name => 'test_item1', :deleted => false, :needed=> true)
		@item2 = @list1.items.create(:name => 'test_item2', :deleted => false, :needed=> false)
		@item3 = @list1.items.create(:name => 'test_item3', :deleted => true,  :needed=> true)
		@item4 = @list1.items.create(:name => 'test_item4', :deleted => true,  :needed=> false)

		@list2 = List.create(:name => 'test_list2')
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

end
