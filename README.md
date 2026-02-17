# RepuTable — Restaurant Review & Reputation Manager

AI-powered review aggregation, sentiment analysis, and reputation management for restaurants.

## 🚀 Features

- **Multi-Platform Review Aggregation**: Connect Google, Facebook, TripAdvisor, and Yelp accounts
- **AI-Powered Sentiment Analysis**: Automatically analyze review sentiment and categorize feedback
- **Smart Reply Generation**: AI-generated reply suggestions with customizable tones
- **Customer Feedback Campaigns**: QR code campaigns to collect private feedback before public reviews
- **Real-time Analytics**: Dashboard with rating trends, sentiment scores, and performance metrics
- **Multi-Location Management**: Manage multiple restaurant locations from one account
- **Team Collaboration**: Multi-user accounts with role-based permissions

## 🛠 Tech Stack

- **Backend**: Ruby on Rails 8.1.2
- **Database**: PostgreSQL with JSONB support
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **WebSockets**: Solid Cable
- **AI Integration**: OpenAI GPT-4o-mini for sentiment analysis and reply generation
- **Multi-Tenancy**: acts_as_tenant for account isolation
- **Authentication**: Rails 8 built-in authentication
- **Deployment**: Docker-ready with Kamal

## 🏗 Architecture

### Models & Relationships

```
Account (Multi-tenant root)
├── Users (Team members)
├── Locations (Restaurant locations)
│   ├── Platform Connections (API integrations)
│   ├── Reviews (Aggregated reviews)
│   └── Campaigns (Feedback campaigns)
├── Reviews (All reviews across locations)
└── Campaign Responses (Customer feedback)
```

### Key Services

- `Reviews::SentimentAnalyzer` - AI-powered sentiment analysis
- `Replies::Generator` - AI reply generation with tone customization
- `Campaigns::QrGenerator` - QR code generation for feedback campaigns

### Background Jobs

- `AnalyzeSentimentJob` - Process review sentiment
- `GenerateReplyJob` - Create AI reply drafts
- `SyncReviewsJob` - Sync reviews from platforms (extensible)

## 🔧 Setup Instructions

### Prerequisites

- Ruby 3.2+
- PostgreSQL 16+
- Node.js 18+ (for asset pipeline)
- OpenAI API key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/sumarx/reputable.git
   cd reputable
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Configure environment variables**
   ```bash
   # Create .env file or set environment variables
   export OPENAI_API_KEY=your_openai_api_key_here
   export APP_HOST=localhost:3000  # For production deployment
   ```

5. **Start the application**
   ```bash
   # Development with live CSS compilation
   bin/dev
   
   # Or just the Rails server
   rails server
   ```

### 🧪 Test Data

The seed file creates realistic test data including:
- **Account**: Masosa Cafe
- **Login**: admin@reputable.io / password123
- **Locations**: Masosa Main Branch, Masosa GT Road
- **Reviews**: 33 reviews with varied ratings and sentiments
- **Campaigns**: 2 QR code campaigns

#### Public Campaign URLs (for testing)
- http://localhost:3000/c/masosa-main-feedback
- http://localhost:3000/c/masosa-gt-road-survey

## 📊 Key Features Breakdown

### 1. Dashboard
- Business overview with key metrics
- Rating trends over time
- Recent reviews feed
- Quick action buttons

### 2. Review Management
- Filterable review feed (platform, sentiment, rating, location)
- Individual review pages with full details
- AI reply generation with multiple tone options
- Sentiment analysis with category breakdown

### 3. Location Management
- Add/edit restaurant locations
- Platform connection status
- Location-specific analytics

### 4. Campaign Management
- Create QR code feedback campaigns
- Configurable positive rating threshold
- Smart routing: positive feedback → public reviews, negative → private feedback
- Campaign performance analytics

### 5. Public Feedback Interface
- Mobile-optimized feedback forms
- Interactive star rating
- Conditional flow based on rating
- Clean, branded customer experience

### 6. Analytics
- Rating distribution charts
- Sentiment trend analysis
- Platform comparison metrics
- Response rate tracking

## 🔒 Security & Multi-Tenancy

- **Account Isolation**: Complete data separation using acts_as_tenant
- **Authentication**: Secure password hashing with Rails built-in auth
- **Token Encryption**: Platform API tokens encrypted with Lockbox
- **CSRF Protection**: Built-in Rails CSRF protection
- **SQL Injection Prevention**: Parameterized queries throughout

## 🚀 Deployment

### Docker Deployment (Recommended)

```bash
# Build and deploy with Kamal (included)
kamal deploy
```

### Manual Deployment

1. Set environment variables:
   ```bash
   export RAILS_ENV=production
   export OPENAI_API_KEY=your_key
   export APP_HOST=your-domain.com
   ```

2. Setup database:
   ```bash
   rails db:migrate
   ```

3. Compile assets:
   ```bash
   rails tailwindcss:build
   rails assets:precompile
   ```

4. Start services:
   ```bash
   # Background jobs
   rails solid_queue:start
   
   # Web server
   rails server -e production
   ```

## 🔮 Future Enhancements

### Platform Integrations
- Google My Business API integration
- Facebook Graph API for reviews
- TripAdvisor Content API
- Yelp Fusion API
- Real-time webhook notifications

### AI Features
- Advanced sentiment categorization
- Competitor analysis
- Review response optimization
- Customer satisfaction prediction

### Business Features
- White-label solutions
- Advanced analytics and reporting
- Team collaboration tools
- API for third-party integrations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is proprietary software. All rights reserved.

## 💡 MVP Status

This is a fully functional MVP with:
- ✅ Complete user authentication and multi-tenancy
- ✅ Database schema with all required models
- ✅ AI-powered sentiment analysis
- ✅ Reply generation system
- ✅ Customer feedback campaigns
- ✅ Modern SaaS dashboard UI
- ✅ Background job processing
- ✅ Comprehensive seed data
- ✅ Production-ready architecture

**Ready for Demo & User Testing** 🎉

---

Built with ❤️ using Rails 8 and modern web technologies.