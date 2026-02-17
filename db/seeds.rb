# Clear existing data in development
if Rails.env.development?
  puts "🧹 Clearing existing data..."
  CampaignResponse.destroy_all
  Campaign.destroy_all
  ReplyDraft.destroy_all
  Review.destroy_all
  NotificationSettings.destroy_all
  PlatformConnection.destroy_all
  Location.destroy_all
  Session.destroy_all
  User.destroy_all
  Account.destroy_all
end

puts "🌱 Creating seed data..."

# Create Account
account = Account.create!(
  name: "Masosa Cafe",
  slug: "masosa-cafe",
  plan: "starter",
  subscription_status: "trialing"
)

puts "✅ Created account: #{account.name}"

# Create User
user = User.create!(
  account: account,
  email_address: "admin@reputable.io",
  password: "password123",
  password_confirmation: "password123",
  name: "Admin User",
  role: "admin"
)

puts "✅ Created user: #{user.email_address}"

# Create Locations
location1 = Location.create!(
  account: account,
  name: "Masosa Main Branch",
  address: "123 Main Street",
  city: "Downtown",
  country: "United States",
  phone: "+1-555-0123",
  latitude: 40.7128,
  longitude: -74.0060
)

location2 = Location.create!(
  account: account,
  name: "Masosa GT Road",
  address: "456 GT Road",
  city: "Uptown",
  country: "United States",
  phone: "+1-555-0124",
  latitude: 40.7589,
  longitude: -73.9851
)

puts "✅ Created locations: #{location1.name}, #{location2.name}"

# Create Platform Connections
PlatformConnection.create!(
  location: location1,
  platform: "google",
  external_id: "google_place_123",
  status: "active",
  last_synced_at: 1.day.ago
)

PlatformConnection.create!(
  location: location2,
  platform: "facebook",
  external_id: "facebook_page_456",
  status: "active",
  last_synced_at: 2.days.ago
)

puts "✅ Created platform connections"

# Create Reviews with varied ratings, sentiments, and platforms
review_data = [
  {
    location: location1,
    platform: "google",
    reviewer_name: "Sarah Johnson",
    rating: 5,
    body: "Amazing coffee and excellent service! The barista was so friendly and the atmosphere is perfect for working. Will definitely be coming back!",
    sentiment: "positive",
    sentiment_score: 0.8,
    categories: ["food", "service", "atmosphere"],
    published_at: 1.day.ago
  },
  {
    location: location1,
    platform: "google",
    reviewer_name: "Mike Chen",
    rating: 4,
    body: "Great coffee, good location. Service was a bit slow during lunch rush but overall a solid experience.",
    sentiment: "positive",
    sentiment_score: 0.6,
    categories: ["food", "service", "location"],
    published_at: 2.days.ago
  },
  {
    location: location1,
    platform: "facebook",
    reviewer_name: "Emily Rodriguez",
    rating: 2,
    body: "Disappointed with the service today. Coffee was lukewarm and the staff seemed overwhelmed. The place was also quite dirty.",
    sentiment: "negative",
    sentiment_score: -0.7,
    categories: ["service", "food", "cleanliness"],
    published_at: 3.days.ago
  },
  {
    location: location2,
    platform: "google",
    reviewer_name: "David Thompson",
    rating: 5,
    body: "Best cafe in the area! Love the cozy atmosphere and the pastries are incredible. Staff is always welcoming.",
    sentiment: "positive",
    sentiment_score: 0.9,
    categories: ["food", "atmosphere", "service"],
    published_at: 1.week.ago
  },
  {
    location: location2,
    platform: "tripadvisor",
    reviewer_name: "Lisa Park",
    rating: 3,
    body: "Okay coffee, nothing special. Prices are reasonable but the wifi was spotty. Good for a quick coffee but wouldn't stay to work.",
    sentiment: "neutral",
    sentiment_score: 0.1,
    categories: ["food", "value", "location"],
    published_at: 5.days.ago
  },
  {
    location: location1,
    platform: "yelp",
    reviewer_name: "Robert Wilson",
    rating: 1,
    body: "Terrible experience. Wrong order, rude staff, and overpriced for what you get. Won't be returning.",
    sentiment: "negative",
    sentiment_score: -0.9,
    categories: ["service", "value", "staff"],
    published_at: 1.week.ago
  },
  {
    location: location2,
    platform: "google",
    reviewer_name: "Jennifer Adams",
    rating: 4,
    body: "Nice quiet spot for meetings. Coffee is consistently good and the wifi is reliable. Could use more seating though.",
    sentiment: "positive",
    sentiment_score: 0.5,
    categories: ["atmosphere", "food", "location"],
    published_at: 3.days.ago
  },
  {
    location: location1,
    platform: "facebook",
    reviewer_name: "Anonymous",
    rating: 5,
    body: "Love this place! The seasonal drinks are creative and delicious. Staff remembers my usual order. Great local business!",
    sentiment: "positive",
    sentiment_score: 0.8,
    categories: ["food", "service"],
    published_at: 2.weeks.ago
  }
]

# Add more reviews to reach 30+
additional_reviews = []
platforms = %w[google facebook yelp tripadvisor]
names = ["Alex Brown", "Maria Garcia", "Tom Anderson", "Nina Patel", "Chris Lee", "Amanda White", "Jason Kim", "Rachel Green", "Steve Miller", "Diana Ross", "Paul Simon", "Grace Kelly", "Frank Ocean", "Taylor Swift", "Ed Sheeran", "Adele Johnson", "Bruno Mars", "Rihanna Smith", "Drake Wilson", "Beyonce Davis", "Jay-Z Brown", "Kanye West"]

(1..25).each do |i|
  rating = [1, 2, 3, 4, 5].sample
  sentiment = case rating
              when 1, 2 then "negative"
              when 3 then "neutral"
              when 4, 5 then "positive"
              end
  
  sentiment_score = case sentiment
                   when "negative" then (rand(-90..-30) / 100.0).round(2)
                   when "neutral" then (rand(-20..20) / 100.0).round(2)
                   when "positive" then (rand(30..90) / 100.0).round(2)
                   end

  bodies = {
    positive: [
      "Great experience overall! Really enjoyed our visit.",
      "Excellent service and quality. Highly recommend!",
      "Love coming here! Always consistent and friendly.",
      "Amazing food and wonderful atmosphere.",
      "Best coffee in town! Staff is super friendly."
    ],
    neutral: [
      "It's okay, nothing special but decent enough.",
      "Average experience. Could be better, could be worse.",
      "Fine for a quick bite. Nothing to write home about.",
      "Decent coffee and service. Pretty standard.",
      "Not bad, but I've had better elsewhere."
    ],
    negative: [
      "Very disappointed with the service and quality.",
      "Won't be coming back. Poor experience overall.",
      "Overpriced and underwhelming. Not impressed.",
      "Service was slow and food was cold.",
      "Dirty tables and inattentive staff. Needs improvement."
    ]
  }

  additional_reviews << {
    location: [location1, location2].sample,
    platform: platforms.sample,
    reviewer_name: names.sample,
    rating: rating,
    body: bodies[sentiment.to_sym].sample,
    sentiment: sentiment,
    sentiment_score: sentiment_score,
    categories: ["food", "service", "atmosphere", "value", "cleanliness"].sample(rand(1..3)),
    published_at: rand(30).days.ago
  }
end

all_reviews = review_data + additional_reviews

all_reviews.each_with_index do |review_attrs, index|
  Review.create!(
    account: account,
    location: review_attrs[:location],
    platform: review_attrs[:platform],
    external_review_id: "ext_review_#{index + 1}_#{review_attrs[:platform]}",
    reviewer_name: review_attrs[:reviewer_name],
    rating: review_attrs[:rating],
    body: review_attrs[:body],
    sentiment: review_attrs[:sentiment],
    sentiment_score: review_attrs[:sentiment_score],
    categories: review_attrs[:categories],
    published_at: review_attrs[:published_at],
    reply_status: "pending"
  )
end

puts "✅ Created #{all_reviews.count} reviews"

# Update location stats
[location1, location2].each(&:update_stats!)
puts "✅ Updated location statistics"

# Create Campaigns
campaign1 = Campaign.create!(
  account: account,
  location: location1,
  name: "Main Branch QR Feedback",
  campaign_type: "qr",
  slug: "masosa-main-feedback",
  positive_threshold: 4,
  redirect_platform: "google",
  active: true
)

campaign2 = Campaign.create!(
  account: account,
  location: location2,
  name: "GT Road Customer Survey",
  campaign_type: "qr",
  slug: "masosa-gt-road-survey",
  positive_threshold: 4,
  redirect_platform: "facebook",
  active: true
)

puts "✅ Created campaigns: #{campaign1.name}, #{campaign2.name}"

# Create Campaign Responses
campaign_responses = [
  { campaign: campaign1, rating: 5, feedback: "Love the coffee here!", customer_name: "Happy Customer", outcome: "redirect" },
  { campaign: campaign1, rating: 4, feedback: "Good service, will come back", customer_name: "John Doe", outcome: "redirect" },
  { campaign: campaign1, rating: 2, feedback: "Coffee was cold and service slow", customer_name: "Disappointed Customer", customer_phone: "+1-555-9999", outcome: "private" },
  { campaign: campaign2, rating: 5, feedback: "Amazing pastries!", outcome: "redirect" },
  { campaign: campaign2, rating: 3, feedback: "Okay experience, nothing special", outcome: "private" },
  { campaign: campaign2, rating: 4, feedback: "Nice atmosphere for work", customer_name: "Remote Worker", outcome: "redirect" }
]

campaign_responses.each do |response_attrs|
  CampaignResponse.create!(response_attrs)
end

# Update campaign counters manually since we're creating responses directly
campaign1.update!(responses_count: 3, redirects_count: 2)
campaign2.update!(responses_count: 3, redirects_count: 2)

puts "✅ Created #{campaign_responses.count} campaign responses"

# Create some reply drafts for negative reviews
negative_reviews = Review.where(sentiment: "negative").limit(3)
negative_reviews.each do |review|
  ReplyDraft.create!(
    review: review,
    body: "Thank you for your feedback. We sincerely apologize for not meeting your expectations. We'd love the opportunity to make this right. Please contact us directly so we can discuss your experience further.",
    tone: "professional",
    status: "draft"
  )
end

puts "✅ Created reply drafts for negative reviews"

puts "\n🎉 Seed data created successfully!"
puts "\n📊 Summary:"
puts "- Account: #{Account.count}"
puts "- Users: #{User.count}"
puts "- Locations: #{Location.count}"
puts "- Platform Connections: #{PlatformConnection.count}"
puts "- Reviews: #{Review.count}"
puts "- Campaigns: #{Campaign.count}"
puts "- Campaign Responses: #{CampaignResponse.count}"
puts "- Reply Drafts: #{ReplyDraft.count}"
puts "\n🔑 Login credentials:"
puts "Email: admin@reputable.io"
puts "Password: password123"
puts "\n🔗 Public campaign URLs:"
puts "- #{campaign1.qr_code_url}"
puts "- #{campaign2.qr_code_url}"