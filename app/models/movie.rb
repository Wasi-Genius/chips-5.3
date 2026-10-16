class Movie < ApplicationRecord
  RATINGS = %w[G PG PG-13 R].freeze

  def self.all_ratings
    RATINGS
  end

  def self.with_ratings(ratings_list)
    return all if ratings_list.blank?

    where(rating: ratings_list)
  end

  def self.order_by(sort_by)
    case sort_by
    when "title"
      title_order = connection.adapter_name == "PostgreSQL" ? 'title COLLATE "C" ASC' : "title COLLATE BINARY ASC"
      order(Arel.sql(title_order))
    when "release_date"
      order(release_date: :asc)
    else
      order(title: :asc)
    end
  end
end
