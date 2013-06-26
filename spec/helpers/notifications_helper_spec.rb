require'spec_helper'

describe NotificationsHelper do

  describe '#time_ago_in_words_if_lt_one_week_otherwise_date' do

    context "when the notification was sent less than one week ago" do
      time_from_lt_a_week_ago = DateTime.new(2013,6,27,15,0,0,'-4') - 5.days

      it "returns the date using words + 'ago'" do
        expect(helper.pretty_time(time_from_lt_a_week_ago)).to eq("5 days ago")
      end
    end

    context "when the notification was sent more than one week ago but less than a year ago" do
      time_from_gt_a_week_ago = DateTime.new(2013,6,27,15,0,0,'-4') - 15.days

      it "returns the date in 'Month DD' format" do
        expect(helper.pretty_time(time_from_gt_a_week_ago)).to eq("June 12")
      end
    end

    context "when the notification was sent more than one a year ago" do
      time_from_gt_a_year_ago = DateTime.new(2013,6,27,15,0,0,'-4') - 1.year - 15.days

      it "returns the date in mm/dd/yyyy format" do
        expect(helper.pretty_time(time_from_gt_a_year_ago)).to eq("06/12/2012")
      end
    end

  end
end
