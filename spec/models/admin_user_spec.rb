# == Schema Information
#
# Table name: admin_users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require "spec_helper"

describe AdminUser do
  before :each do
    @admin_user = build(:admin_user)
  end

  describe "complex password" do
    it "should not allow a password with no digits" do
      @admin_user.password = @admin_user.password_confirmation = "Password"
      @admin_user.should_not be_valid
    end

    it "should not allow a password with no upper case letters" do
      @admin_user.password = @admin_user.password_confirmation = "password1"
      @admin_user.should_not be_valid
    end

    it "should not allow a password with no lower case letters" do
      @admin_user.password = @admin_user.password_confirmation = "PASSWORD1"
      @admin_user.should_not be_valid
    end

    it "should allow a password with lower case letters, upper case letters, and a digit" do
      @admin_user.password = @admin_user.password_confirmation = "Password1"
      @admin_user.should be_valid
    end
  end
end
