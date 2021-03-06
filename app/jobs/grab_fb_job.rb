require 'sidekiq-scheduler'

class GrabFbJob < ApplicationJob
  queue_as :default

  def perform(*args)
    count = FbDb.count

    @fb = Koala::Facebook::API.new(CONFIG.FB_TOKEN)

    @fan = get_3_days_data("page_fans").first.first.second
    @fan_add = get_3_days_data("page_fan_adds_unique")
    @fan_lost = get_3_days_data("page_fan_removes_unique")
    @page = get_3_days_data("page_impressions_unique")
    @post = get_3_days_data("page_posts_impressions_unique")
    @enagement = get_3_days_data("page_engaged_users")
    @negative = get_3_days_data("page_negative_feedback_unique")
    @post_enagement = get_3_days_data("page_post_engagements")
    @link_click = get_3_days_data("page_consumptions_by_consumption_type")
    @gender = get_3_days_data("page_fans_gender_age")

    set_fb_db

    puts "add #{FbDb.count - count} fb data"
  end

  def get_3_days_data(what)
    @fb.get_object("278666028863859/insights/#{what}?fields=values&date_preset=last_3_days")
  end

  def set_fb_db
    i = 0

    while i < @fan.length
      db_date = FbDb.last.date.to_date
      api_date = @fan[i]["end_time"].to_date

      if db_date > api_date
      elsif !@gender[0].nil? && !@gender[0]["values"][i].nil? && db_date == @gender[0]["values"][i]["end_time"].to_date
        old = FbDb.last
        old.fans_female_day = @gender[0]["values"][i]["value"].values[0..6].inject(0, :+)
        old.fans_male_day = @gender[0]["values"][i]["value"].values[7..13].inject(0, :+)
        old.fans_13_17 = @gender[0]["values"][i]["value"].values[0, 7].inject(0, :+)
        old.fans_18_24 = @gender[0]["values"][i]["value"].values[1, 8].inject(0, :+)
        old.fans_25_34 = @gender[0]["values"][i]["value"].values[2, 9].inject(0, :+)
        old.fans_35_44 = @gender[0]["values"][i]["value"].values[3, 10].inject(0, :+)
        old.fans_45_54 = @gender[0]["values"][i]["value"].values[4, 11].inject(0, :+)
        old.fans_55_64 = @gender[0]["values"][i]["value"].values[5, 12].inject(0, :+)
        old.fans_65 = @gender[0]["values"][i]["value"].values[6, 13].inject(0, :+)
        old.save!
      elsif db_date == api_date
      elsif api_date >= Date.today
      else
        if @fan_add[0]["values"][i]["end_time"] != api_date
          puts "fan_add"
          puts api_date
          puts @fan_add[0]["values"][i]["end_time"]
          break
        elsif @fan_lost[0]["values"][i]["end_time"] != api_date 
          puts "fan_lost"
          puts api_date
          puts @fan_lost[0]["values"][i]["end_time"]
          break
        elsif @page[0]["values"][i]["end_time"] != api_date 
          puts "page"
          puts api_date
          puts @page[0]["values"][i]["end_time"]
          break
        elsif @post[0]["values"][i]["end_time"] != api_date 
          puts "post"
          puts api_date
          puts @post[0]["values"][i]["end_time"]
          break
        elsif @enagement[0]["values"][i]["end_time"] != api_date 
          puts "enagement"
          puts api_date
          puts @enagement[0]["values"][i]["end_time"]
          break
        elsif @negative[0]["values"][i]["end_time"] != api_date 
          puts "negative"
          puts api_date
          puts @negative[0]["values"][i]["end_time"]
          break
        elsif @post_enagement[0]["values"][i]["end_time"] != api_date 
          puts "fan_lost"
          puts api_date
          puts @post_enagement[0]["values"][i]["end_time"]
          break
        elsif @link_click[0]["values"][i]["end_time"] != api_date 
          puts "link_click"
          puts api_date
          puts @link_click[0]["values"][i]["end_time"]
          break
        elsif @gender[0]["values"][i].nil?
          FbDb.create(
            date: @fan[i]["end_time"],
            fans: @fan[i]["value"],
            fans_adds_day: @fan_add[0]["values"][i]["value"],
            fans_losts_day: @fan_lost[0]["values"][i]["value"],
            page_users_day: @page[0]["values"][i]["value"],
            posts_users_day: @post[0]["values"][i]["value"],
            fans_adds_week: @fan_add[1]["values"][i]["value"],
            fans_losts_week: @fan_lost[1]["values"][i]["value"],
            page_users_week: @page[1]["values"][i]["value"],
            posts_users_week: @post[1]["values"][i]["value"],
            fans_adds_month: @fan_add[2]["values"][i]["value"],
            fans_losts_month: @fan_lost[2]["values"][i]["value"],
            page_users_month: @page[2]["values"][i]["value"],
            posts_users_month: @post[2]["values"][i]["value"],
            post_enagements_day: @post_enagement[0]["values"][i]["value"],
            negative_users_day: @negative[0]["values"][i]["value"],
            post_enagements_week: @post_enagement[1]["values"][i]["value"],
            negative_users_week: @negative[1]["values"][i]["value"],
            post_enagements_month: @post_enagement[2]["values"][i]["value"],
            negative_users_month: @negative[2]["values"][i]["value"],
            link_clicks_day: @link_click[0]["values"][i]["value"]["link clicks"],
            link_clicks_week: @link_click[1]["values"][i]["value"]["link clicks"],
            link_clicks_month: @link_click[2]["values"][i]["value"]["link clicks"],
            enagements_users_day: @enagement[0]["values"][i]["value"],
            enagements_users_week: @enagement[1]["values"][i]["value"],
            enagements_users_month: @enagement[2]["values"][i]["value"]
            )
          i += 1
        elsif @gender[0]["values"][i]["end_time"] != api_date
          puts "gender"
          puts api_date
          puts @gender[0]["values"][i]["end_time"]
          break
        else
          FbDb.create(
            date: @fan[i]["end_time"],
            fans: @fan[i]["value"],
            fans_adds_day: @fan_add[0]["values"][i]["value"],
            fans_losts_day: @fan_lost[0]["values"][i]["value"],
            page_users_day: @page[0]["values"][i]["value"],
            posts_users_day: @post[0]["values"][i]["value"],
            fans_adds_week: @fan_add[1]["values"][i]["value"],
            fans_losts_week: @fan_lost[1]["values"][i]["value"],
            page_users_week: @page[1]["values"][i]["value"],
            posts_users_week: @post[1]["values"][i]["value"],
            fans_adds_month: @fan_add[2]["values"][i]["value"],
            fans_losts_month: @fan_lost[2]["values"][i]["value"],
            page_users_month: @page[2]["values"][i]["value"],
            posts_users_month: @post[2]["values"][i]["value"],
            post_enagements_day: @post_enagement[0]["values"][i]["value"],
            negative_users_day: @negative[0]["values"][i]["value"],
            post_enagements_week: @post_enagement[1]["values"][i]["value"],
            negative_users_week: @negative[1]["values"][i]["value"],
            post_enagements_month: @post_enagement[2]["values"][i]["value"],
            negative_users_month: @negative[2]["values"][i]["value"],
            link_clicks_day: @link_click[0]["values"][i]["value"]["link clicks"],
            link_clicks_week: @link_click[1]["values"][i]["value"]["link clicks"],
            link_clicks_month: @link_click[2]["values"][i]["value"]["link clicks"],
            fans_female_day: @gender[0]["values"][i]["value"].values[0..6].inject(0, :+),
            fans_male_day: @gender[0]["values"][i]["value"].values[7..13].inject(0, :+),
            fans_13_17: @gender[0]["values"][i]["value"].values[0, 7].inject(0, :+),
            fans_18_24: @gender[0]["values"][i]["value"].values[1, 8].inject(0, :+),
            fans_25_34: @gender[0]["values"][i]["value"].values[2, 9].inject(0, :+),
            fans_35_44: @gender[0]["values"][i]["value"].values[3, 10].inject(0, :+),
            fans_45_54: @gender[0]["values"][i]["value"].values[4, 11].inject(0, :+),
            fans_55_64: @gender[0]["values"][i]["value"].values[5, 12].inject(0, :+),
            fans_65: @gender[0]["values"][i]["value"].values[6, 13].inject(0, :+),
            enagements_users_day: @enagement[0]["values"][i]["value"],
            enagements_users_week: @enagement[1]["values"][i]["value"],
            enagements_users_month: @enagement[2]["values"][i]["value"]
            )
        end
      end
      i += 1
    end
  end
end
