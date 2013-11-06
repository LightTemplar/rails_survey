require "spec_helper"

describe Device do
  it "should be in the danger zone if last survey is too old" do
    device = Device.new
    survey = Survey.new
    survey.stub(:updated_at).and_return(1.day.ago)
    device.stub(:last_survey).and_return(survey)
    device.danger_zone?.should be_true
  end

  it "should not be in the danger zone if last survey is new" do
    device = Device.new
    survey = Survey.new
    survey.stub(:updated_at).and_return(1.minute.ago)
    device.stub(:last_survey).and_return(survey)
    device.danger_zone?.should be_false
  end
end
