require 'rails_helper'

RSpec.describe "people/edit", :type => :view do
  before(:each) do
    @person = assign(:person, Person.create!(
      :gender => "MyString",
      :height => 1.5,
      :weight => 1.5
    ))
  end

  it "renders the edit person form" do
    render

    assert_select "form[action=?][method=?]", person_path(@person), "post" do

      assert_select "input#person_gender[name=?]", "person[gender]"

      assert_select "input#person_height[name=?]", "person[height]"

      assert_select "input#person_weight[name=?]", "person[weight]"
    end
  end
end
