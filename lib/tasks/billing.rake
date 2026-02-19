namespace :billing do
  desc "Generate monthly invoices for active subscriptions"
  task generate_invoices: :environment do
    puts "Generating invoices..."
    
    # Find subscriptions that need invoices (current period ending today or in the past)
    subscriptions = Subscription.joins(:plan)
                               .where(status: ['trial', 'active'])
                               .where('current_period_end <= ?', Date.current)
    
    subscriptions.find_each do |subscription|
      Billing::GenerateInvoiceJob.perform_later(subscription.id)
    end
    
    puts "Scheduled invoice generation for #{subscriptions.count} subscriptions"
  end

  desc "Check for overdue invoices and send reminders"
  task check_overdue: :environment do
    puts "Checking for overdue invoices..."
    Billing::CheckOverdueJob.perform_later
    puts "Scheduled overdue check"
  end

  desc "Suspend accounts with overdue payments"
  task suspend_accounts: :environment do
    puts "Checking accounts for suspension..."
    Billing::SuspendAccountJob.perform_later
    puts "Scheduled account suspension check"
  end

  desc "Run all billing tasks"
  task run_all: :environment do
    Rake::Task['billing:generate_invoices'].invoke
    Rake::Task['billing:check_overdue'].invoke  
    Rake::Task['billing:suspend_accounts'].invoke
  end
end