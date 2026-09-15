# frozen_string_literal: true

class AiNoteService
  DEFAULT_MODEL = "openai/gpt-4o-mini"

  def initialize(model: nil)
    @model = model || ENV.fetch("OPENROUTER_MODEL", DEFAULT_MODEL)
    @client = OpenAI::Client.new
  end

  def generate(category:, subcategory:, context: nil)
    system_prompt = build_system_prompt
    user_prompt = build_user_prompt(category: category, subcategory: subcategory, context: context)

    response = @client.chat(
      parameters: {
        model: @model,
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: user_prompt }
        ],
        temperature: 0.6
      }
    )

    if response.is_a?(Hash) && response["error"]
      error_message = response.dig("error", "message") || "Erro ao comunicar com a IA"
      raise StandardError, error_message
    end

    content = response.dig("choices", 0, "message", "content")
    raise StandardError, "Nenhum conteúdo retornado pela IA" if content.blank?

    clean_content(content)
  end

  private

  def build_system_prompt
    <<~PROMPT
      Você é um engenheiro especialista em elevadores e transporte vertical, responsável por redigir notas técnicas detalhadas, profissionais e padronizadas para vistorias, consultorias, laudos técnicos e inspeções de elevadores.

      Seu objetivo é gerar o texto técnico (corpo da nota) baseado na Categoria e Subcategoria fornecidas.

      Diretrizes de redação:
      - Linguagem técnica formal, clara, objetiva e persuasiva em português do Brasil.
      - Descreva a solução, tecnologia ou componente técnico específico.
      - Apresente de forma estruturada as vantagens operacionais, funcionais e de segurança da solução para o condomínio/edifício e passageiros.
      - Siga a estrutura de tópicos de vantagens (exemplo: Conforto, Maior vida útil e menor consumo de energia, Segurança, Confiabilidade) ou itens correspondentes ao tema técnico da subcategoria.
      - Retorne APENAS o texto pronto da nota técnica que será inserido diretamente no corpo da nota. NÃO inclua saudações, introduções ("Aqui está a nota..."), aspas externas ou blocos markdown do tipo ```.

      Exemplo de referência de estilo e estrutura:
      "O fabricante deste elevador possui moderno quadro de comando com acionamento VVVF: VANTAGENS: Conforto: com aceleração e paradas suaves, garantidas pelo cálculo rigoroso de velocidade a cada instante, proporciona nivelamento preciso em todos os pavimentos, independentemente do número de pessoas na cabina; Maior vida útil e menor consumo de energia: o processamento eletrônico de dados e o apurado controle de velocidade otimizam o atendimento ao tráfego e reduzem o desgaste de redutores, freios, polias e cabos de tração, garantindo economia e maior vida útil a todo o conjunto de tração dos elevadores do edifício; Segurança: realiza permanentemente rotinas de auto teste, proporcionando maior segurança para passageiros e usuários; Confiabilidade: tem grande poder de processamento de dados e memorização de ocorrências de falhas, agilizando o atendimento e os serviços de manutenção preventiva."
    PROMPT
  end

  def build_user_prompt(category:, subcategory:, context:)
    prompt_parts = []
    prompt_parts << "Categoria: #{category.presence || 'Geral'}"
    prompt_parts << "Subcategoria: #{subcategory.presence || 'Geral'}"
    prompt_parts << "Contexto adicional ou observações: #{context}" if context.present?
    prompt_parts << "\nGere a nota técnica completa para este item de elevador seguindo o padrão de consultoria técnica."
    prompt_parts.join("\n")
  end

  def clean_content(text)
    cleaned = text.strip
    cleaned = cleaned.sub(/\A```(?:markdown|text)?\n?/, "").sub(/\n?```\z/, "").strip
    if (cleaned.start_with?('"') && cleaned.end_with?('"')) || (cleaned.start_with?("'") && cleaned.end_with?("'"))
      cleaned = cleaned[1..-2].strip
    end
    cleaned
  end
end
