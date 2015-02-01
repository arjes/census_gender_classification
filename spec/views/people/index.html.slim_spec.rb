require 'rails_helper'

RSpec.describe "people/index", :type => :view do
  before(:each) do
    assign(:people, [
      Person.create!(
        :gender => "male",
        :height => 1.5,
        :weight => 2.5
      ),
      Person.create!(
        :gender => "male",
        :height => 1.5,
        :weight => 2.5
      )
    ])
  end

  it "renders a list of people" do
    render
    assert_select "tbody>tr>td", :text => "male".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 2.5.to_s, :count => 2
  end
end
