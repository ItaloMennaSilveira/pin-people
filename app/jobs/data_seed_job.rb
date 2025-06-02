class DataSeedJob
  include Sidekiq::Job

  DEFAULT_PATH = 'tmp/data/data.csv'.freeze

  def perform(path = nil)
    file_path = path.presence || DEFAULT_PATH
    data_array = CsvReaderService.new(file_path).call

    errors = []

    data_array.each_with_index do |data, index|
      company = find_or_create_department(data['n0_empresa'], :company)
      board = find_or_create_department(data['n1_diretoria'], :board, company)
      management = find_or_create_department(data['n2_gerencia'], :management, board)
      coordination = find_or_create_department(data['n3_coordenacao'], :coordination, management)
      area = find_or_create_department(data['n4_area'], :area, coordination)

      user = find_or_create_user(data, area)

      create_survey_response(user, data)
    rescue StandardError => e
      Rails.logger.error "[DataSeedJob] Erro na linha #{index + 1}: #{e.message}"
      Rails.logger.error data.inspect
      errors << { line: index + 1, message: e.message, data: data }
      next
    end

    if errors.any?
      Rails.logger.warn "[DataSeedJob] Finalizado com #{errors.count} erros."
    else
      Rails.logger.info '[DataSeedJob] Importação concluída com sucesso.'
    end
  end

  private

  def find_or_create_department(name, level, parent = nil)
    department = Department.find_or_initialize_by(name: name)
    department.assign_attributes(
      name: name,
      level: Department.levels[level],
      parent: parent,
      company_id: parent&.company_id || parent&.id
    )
    department.save!

    department
  end

  def find_or_create_user(data, area)
    user = User.find_or_initialize_by(company_email: data['email_corporativo'])
    user.assign_attributes(
      name: data['nome'],
      email: data['email'],
      position: data['cargo'],
      function: data['funcao'],
      city: data['localidade'],
      company_tenure: parse_tenure(data['tempo_de_empresa']),
      genre: parse_genre(data['genero']),
      generation: parse_generation(data['geracao']),
      department: area
    )
    user.save!

    user
  end

  def create_survey_response(user, data)
    SurveyResponse.create!(
      user: user,
      response_date: Date.strptime(data['Data da Resposta'], '%d/%m/%Y'),
      interest_in_position: data['Interesse no Cargo'].to_i,
      comments_interest: data['Comentários - Interesse no Cargo'],
      contribution: data['Contribuição'].to_i,
      comments_contribution: data['Comentários - Contribuição'],
      learning_and_development: data['Aprendizado e Desenvolvimento'].to_i,
      comments_learning: data['Comentários - Aprendizado e Desenvolvimento'],
      feedback: data['Feedback'].to_i,
      comments_feedback: data['Comentários - Feedback'],
      manager_interaction: data['Interação com Gestor'].to_i,
      comments_manager_interaction: data['Comentários - Interação com Gestor'],
      career_clarity: data['Clareza sobre Possibilidades de Carreira'].to_i,
      comments_career_clarity: data['Comentários - Clareza sobre Possibilidades de Carreira'],
      permanence_expectation: data['Expectativa de Permanência'].to_i,
      comments_permanence: data['Comentários - Expectativa de Permanência'],
      enps: data['eNPS'].to_i,
      comments_enps: data['[Aberta] eNPS']
    )
  end

  def parse_tenure(value)
    case value&.downcase
    when /menos/
      :less_than_one_year
    when /entre 1 e 2/
      :between_one_and_two_years
    when /entre 2 e 5/
      :between_two_and_five_years
    when /mais/
      :more_than_five_years
    end
  end

  def parse_genre(value)
    case value&.downcase
    when 'masculino' then :male
    when 'feminino' then :female
    else :other
    end
  end

  def parse_generation(value)
    case value&.downcase
    when /boomer/ then :boomer
    when /x/ then :gen_x
    when /y/ then :gen_y
    when /z/ then :gen_z
    when /alpha/ then :gen_alpha
    end
  end
end
