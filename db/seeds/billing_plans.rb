# Create billing plans
puts "Creating billing plans..."

starter_plan = Plan.find_or_create_by(name: "Starter") do |plan|
  plan.price_cents = 200000 # 2,000 PKR
  plan.currency = "PKR"
  plan.max_locations = 1
  plan.max_campaigns = 2
  plan.max_reviews_per_month = 100
  plan.features = {}
  plan.active = true
  plan.position = 1
end

pro_plan = Plan.find_or_create_by(name: "Pro") do |plan|
  plan.price_cents = 500000 # 5,000 PKR
  plan.currency = "PKR"
  plan.max_locations = 3
  plan.max_campaigns = 10
  plan.max_reviews_per_month = -1 # unlimited
  plan.features = {
    "advanced_analytics" => true,
    "priority_support" => true
  }
  plan.active = true
  plan.position = 2
end

business_plan = Plan.find_or_create_by(name: "Business") do |plan|
  plan.price_cents = 1000000 # 10,000 PKR
  plan.currency = "PKR"
  plan.max_locations = 10
  plan.max_campaigns = -1 # unlimited
  plan.max_reviews_per_month = -1 # unlimited
  plan.features = {
    "advanced_analytics" => true,
    "priority_support" => true,
    "white_label" => true,
    "api_access" => true
  }
  plan.active = true
  plan.position = 3
end

puts "Created #{Plan.count} plans: #{Plan.pluck(:name).join(', ')}"

# Give existing accounts trial subscriptions
puts "Setting up trial subscriptions for existing accounts..."

Account.includes(:subscription).find_each do |account|
  next if account.subscription.present?

  # Assign plan based on current plan field
  plan = case account.plan
         when 'starter'
           starter_plan
         when 'professional' 
           pro_plan
         when 'enterprise'
           business_plan
         else
           starter_plan
         end

  trial_ends_at = 14.days.from_now
  
  subscription = account.build_subscription(
    plan: plan,
    status: 'trial',
    trial_ends_at: trial_ends_at,
    current_period_start: Date.current,
    current_period_end: Date.current + 1.month - 1.day
  )
  
  if subscription.save
    puts "Created trial subscription for #{account.name} (#{plan.name} plan)"
  else
    puts "Failed to create subscription for #{account.name}: #{subscription.errors.full_messages.join(', ')}"
  end
end

puts "Billing setup complete!"