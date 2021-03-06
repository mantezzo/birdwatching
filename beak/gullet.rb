# 041718
# preprocesses data

require_relative '../belly/kclusters_implementation/class_kclusters'
require_relative 'twitter_scraper'
#require 'pca'
#require 'matplotlib'

class Gullet

  # updates average
  def avg(avg, size, new_)
      return ((size * avg) + new_)/(size + 1)
  end

  # checks if word is a swear
  def is_swear(word)
      word = word.downcase
      if word.include? "fuck" or word.include? "shit" or word.include? "damn" or word.include? "bitch"
  	return true
      else
  	return false
      end
  end

  # constants for running subprocess
  def process_data(keyword, k, num_users, should_scrape)

    scraper = TwitterData.new()

    if (should_scrape)
      puts "Scraping..."
      scraper.write_userstats_tofile(keyword, num_users)
    end

    # INIT COUNTS
    tweet_num = 0 # total number of tweets

    # INIT AVERAGES
    count_avg = 0 # avg word count
    swear_avg = 0 # avg swear to word ratio


    kcl = KClusters.new
    data = Array.new

    #begin
      file = File.open("beak/users_data.txt", "r")

      while !file.eof?
      	line = file.readline
      	next if line.strip.empty? == true
      	arr = line.split(' ')

      	tweets = File.open("beak/tweets/" + arr[0] + "_tweets.txt")
        all_tweets = tweets.read.split("__END_TWEET__")

        count_avg = 0;

	       all_tweets.each do |tweet|
      	    tarr = tweet.split(' ') # This breaks on new lines in tweets

      	    tweet_num += 1
      	    word_num = tarr.count
            if (tarr.count == 0)
              word_num = 1
            end

      	    count_avg = avg(count_avg, tweet_num, word_num) # something is wrong here...

            swear_num = 0
      	    tarr.each do |w|
          		if is_swear(w)
          		    swear_num += 1
          		end
      	    end

      	    swear_avg = avg(swear_avg, tweet_num, swear_num/word_num) # does this do what you think it does?

      	end
        tweets.close

      	data_point = {
      	    id: arr[0],
      	    followers: arr[1].to_i,
      	    friends: arr[2].to_i,
      	    tweet_count: arr[3].to_i,
	    fav_count: arr[4].to_i,
      	    #count_avg: count_avg,
      	    #swear_avg: swear_avg
      	}
      	data.push(data_point)
      end

      file.close
    #rescue
      #puts "Something went wrong..."
      #return 1 # something went wrong
    #end

    #puts data
    labeled_data = kcl.get_clusters(data, k, false)
    #puts "The entire labeled data set...\n"
    #puts labeled_data

    flat_labeled_data = Array.new()
    labeled_data.each { |point_hash|
      flat_labeled_data.push(point_hash.values.slice(1...point_hash.values.size-1))
    }
    #print flat_labeled_data

    # Another dimensionality reduction technique

    # pca = PCA.new components: 2
    # reduced_data = pca.fit_transform flat_labeled_data
    # print pca.explained_variance_ratio
    # print reduced_data

    features_file = File.open("beak/z_scored_features.txt", "w")
    labels_file = File.open("beak/z_scored_labels.txt", "w")

    labeled_data.each { |point_hash|
      point_hash.values.slice(1...(point_hash.size - 1)).each { |value|
        features_file.write(value)
        features_file.write(" ")
      }
      features_file.write("\n")
    }

    labeled_data.each { |point_hash|
      labels_file.write(point_hash[:label].to_f)
      labels_file.write("\n")
    }

    features_file.close
    labels_file.close

    return 0 # it worked!
  end
end

#gullet = Gullet.new()
#gullet.process_data("cheese", 4, 10, true)
