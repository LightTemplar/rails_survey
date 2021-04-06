require 'rails_helper'

RSpec.describe Center, type: :model do

  before :each do
    @center = build(:center)
  end

  it "is valid with valid attributes" do
    expect(@center).to be_valid
  end

  it "is not valid without an identifier" do
    @center.identifier = nil
    expect(@center).to_not be_valid
  end

  it "is not valid without a name" do
    @center.name = ''
    expect(@center).to_not be_valid
  end

  it "is not valid without a type" do
    @center.center_type = nil
    expect(@center).to_not be_valid
  end

end
