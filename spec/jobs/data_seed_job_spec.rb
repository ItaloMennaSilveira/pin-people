require 'rails_helper'

RSpec.describe DataSeedJob, type: :job do
  let(:file_path) { Rails.root.join('spec/temp/sample_data.csv') }

  before do
    File.write(file_path, <<~CSV)
      n0_empresa;n1_diretoria;n2_gerencia;n3_coordenacao;n4_area;nome;email;email_corporativo;cargo;funcao;localidade;tempo_de_empresa;genero;geracao;Data da Resposta;Interesse no Cargo;Comentários - Interesse no Cargo;Contribuição;Comentários - Contribuição;Aprendizado e Desenvolvimento;Comentários - Aprendizado e Desenvolvimento;Feedback;Comentários - Feedback;Interação com Gestor;Comentários - Interação com Gestor;Clareza sobre Possibilidades de Carreira;Comentários - Clareza sobre Possibilidades de Carreira;Expectativa de Permanência;Comentários - Expectativa de Permanência;eNPS;[Aberta] eNPS
      Empresa A;Diretoria A;Gerência A;Coordenação A;Área A;João;joao@gmail.com;joao@empresa.com;Dev;Backend;SP;Entre 1 e 2 anos;Masculino;Y;01/01/2024;10;;9;;8;;7;;6;;5;;4;;3;;
    CSV
  end

  after { File.delete(file_path) }

  it "processes the CSV and creates records" do
    expect {
      described_class.new.perform(file_path)
    }.to change(User, :count).by(1)
      .and change(Department, :count).by(5)
      .and change(SurveyResponse, :count).by(1)
  end
end
