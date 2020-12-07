class Generator
  require 'faker'
  require 'yaml'
  require 'json'
  Faker::Config.locale = :ru
  FIELDS = %i[name job education previous_job achivments skill travel salary].freeze

  def initialize(params)
    @username = params[:username]
    @name = params[:name]
    @redis = params[:redis]
    @chat_id = params[:chat_id]
  end

  def cv
    FIELDS.each_with_object({}) do |field, hash|
      hash[field] = send(field)
    end
  end

  private

  def name
    (@name || Faker::Name.name) + "\n"
  end

  def jobs
    YAML.safe_load(File.read('jobs.yml'))
  end

  def job
    'Работа: ' + jobs.sample
  end

  def skills
    YAML.safe_load(File.read('skillz.yml'))
  end

  def skill
    skills_count = rand(1..3)
    'Профессиональные навыки: ' + skills_count.times.map { skills.sample }.join(', ')
  end

  def previous_job
    "Ранее работал в #{Faker::Company.name}."
  end

  def salary
    "Желаемая зарплата #{random_salary} рублей"
  end

  def achivments
    "Достижения на предыдущей работе: cоздал #{product}."
  end

  def product
    Faker::Commerce.product_name.downcase
  end

  def travel
    "Рассмотрю переезд в страну - #{Faker::Address.country}."
  end

  def universities
    YAML.safe_load(File.read('universities.yml'))
  end

  def education
    'Образование: ' + universities.sample
  end

  def random_salary
    total =
      case rand(1..100)
      when 1..10
        (1..9).to_a.sample.to_s + ' ' + (0..9).to_a.sample.to_s + '00'
      when 11..50
        (1..9).to_a.sample.to_s + (0..9).to_a.sample.to_s + ' 000'
      when 51..75
        '1' + (0..9).to_a.sample.to_s + (0..9).to_a.sample.to_s + ' 000'
      when 76..90
        '2' + (0..9).to_a.sample.to_s + (0..9).to_a.sample.to_s + ' 000'
      when 91..95
        '3' + (0..9).to_a.sample.to_s + (0..9).to_a.sample.to_s + ' 000'
      when 95..97
        '4' + (0..9).to_a.sample.to_s + (0..9).to_a.sample.to_s + ' 000'
      when 97..99
        '5' + (0..9).to_a.sample.to_s + (0..9).to_a.sample.to_s + ' 000'
      when 100
        (50..99).to_a.sample.to_s + '0 000'
      end
    results = @redis.get(@chat_id)
    biggest = results ? (JSON.parse(results)["biggest"]) : '0'
    biggest = biggest.gsub!(/\D/, '').to_i
    @redis.set(@chat_id, { biggest: total, username: @username }.to_json ) if total.to_i > biggest
    total
  end
end
