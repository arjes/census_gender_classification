require 'rails_helper'

RSpec.describe "people/show", :type => :view do
  before(:each) do
    @person = assign(:person, Person.create!(
      :gender => "male",
      :height => 1.5,
      :weight => 1.5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/male/)
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(/1.5/)
  end
end
