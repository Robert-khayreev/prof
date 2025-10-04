# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data
ProfileInteraction.destroy_all
Profile.destroy_all
User.destroy_all

# Create demo users
user1 = User.create!(
  email: "demo@example.com",
  password: "password",
  password_confirmation: "password"
)

user2 = User.create!(
  email: "test@example.com",
  password: "password",
  password_confirmation: "password"
)

puts "Created user: #{user1.email}"
puts "Created user: #{user2.email}"

# Create sample profiles for user1 (demo@example.com)
user1_profiles = [
  {
    name: "Alex",
    age: 28,
    gender_identity: "non-binary",
    height: 175,
    income_level: "50k-75k",
    description: "Adventure seeker, coffee enthusiast, and dog lover. Always up for trying new restaurants or exploring hiking trails. Looking for someone to share spontaneous road trips with!",
    active: true
  },
  {
    name: "Jordan",
    age: 25,
    gender_identity: "male",
    height: 182,
    income_level: "75k-100k",
    description: "Software engineer by day, aspiring chef by night. I love cooking international cuisines and hosting dinner parties. Bonus points if you can appreciate a good pun!",
    active: true
  },
  {
    name: "Sam",
    age: 30,
    gender_identity: "female",
    height: 168,
    income_level: "30k-50k",
    description: "Fitness enthusiast and yoga instructor. Passionate about wellness and mindful living. When I'm not at the studio, you'll find me at the beach or reading a good book.",
    active: true
  }
]

user1_profiles.each do |profile_data|
  profile = user1.profiles.create!(profile_data)
  puts "Created profile for #{user1.email}: #{profile.name}, #{profile.age}"
end

# Create sample profiles for user2 (test@example.com)
user2_profiles = [
  {
    name: "Taylor",
    age: 27,
    gender_identity: "genderqueer",
    height: 172,
    income_level: "100k-150k",
    description: "Creative soul with a passion for photography and art. I spend my weekends at galleries, concerts, or capturing the city's hidden gems. Let's explore together!",
    active: true
  },
  {
    name: "Morgan",
    age: 29,
    gender_identity: "male",
    height: 178,
    income_level: "150k-200k",
    description: "Entrepreneur with a love for travel. I've been to 35 countries and counting! Always planning my next adventure. Seeking a travel buddy who's ready for new experiences.",
    active: true
  },
  {
    name: "Casey",
    age: 26,
    gender_identity: "female",
    height: 165,
    income_level: "50k-75k",
    description: "Music lover and aspiring guitarist. I love live concerts, vinyl records, and discovering new artists. If you're into indie rock or jazz, we'll get along great!",
    active: true
  }
]

user2_profiles.each do |profile_data|
  profile = user2.profiles.create!(profile_data)
  puts "Created profile for #{user2.email}: #{profile.name}, #{profile.age}"
end

# Create some sample interactions for the first profile of each user
# User1's first profile gets interactions from user2's perspective
first_user1_profile = user1.profiles.first
if first_user1_profile
  10.times do |i|
    ProfileInteraction.create!(
      profile: first_user1_profile,
      viewer_session: SecureRandom.urlsafe_base64,
      action: ['right_swipe', 'left_swipe'].sample,
      time_spent: rand(5..60),
      scroll_depth: rand(20..100),
      image_index: rand(0..2)  # Simulate viewing 1-3 photos
    )
  end
  puts "Created sample interactions for #{first_user1_profile.name}"
end

# User2's first profile gets interactions from user1's perspective
first_user2_profile = user2.profiles.first
if first_user2_profile
  8.times do |i|
    ProfileInteraction.create!(
      profile: first_user2_profile,
      viewer_session: SecureRandom.urlsafe_base64,
      action: ['right_swipe', 'left_swipe'].sample,
      time_spent: rand(5..60),
      scroll_depth: rand(20..100),
      image_index: rand(0..2)  # Simulate viewing 1-3 photos
    )
  end
  puts "Created sample interactions for #{first_user2_profile.name}"
end

puts "\n✅ Seed data created successfully!"
puts "You can now log in and test the application."
puts "Visit http://localhost:3000 to get started."
