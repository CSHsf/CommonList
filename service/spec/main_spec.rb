require 'spec_helper'

describe 'Grocery Service' do
	it 'puts the lotion in the basket' do
		get '/'
		last_response.status.should == 200
		last_response.body.should == 'Hi'
	end
end
