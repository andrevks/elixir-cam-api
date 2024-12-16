# README CAM API

# ElixirCamApi

## Sobre o Projeto

**ElixirCamApi** é uma API construída com Elixir e Phoenix, projetada para gerenciamento eficiente de usuários e câmeras. A aplicação foca em escalabilidade, organização de código e aderência a boas práticas, com funcionalidades que incluem:

- Listagem de usuários e suas câmeras, com suporte a filtros e paginação.
- Notificações para usuários com câmeras específicas, simulando envio de emails.

O projeto foi desenvolvido com o objetivo de demonstrar expertise em desenvolvimento backend, destacando uma arquitetura limpa, atenção à performance e uma abordagem voltada para testes. Todos os dados são formatados em JSON, garantindo integração fluida com aplicações frontend ou outros serviços.

---

## Funcionalidades Principais

- **Gerenciamento de Usuários e Câmeras**:
    - Cada usuário pode ter múltiplas câmeras com atributos como marca e status ativo/inativo.
- **Seed do Banco de Dados**:
    - Um script inicializa o banco com 1.000 usuários, cada um com 50 câmeras configuradas com marcas e status aleatórios.
- **Paginação e Filtros**:
    - O endpoint `/api/cameras` suporta paginação e filtros para nome e marca das câmeras, além de permitir ordenação.
- **Envio de Notificações**:
    - O endpoint `/api/notify-users` simula o envio de notificações para usuários com câmeras da marca "Hikvision".
- **CORS**:
    - Configuração para permitir chamadas de aplicações frontend.
- **Logs**:
    - Configuração de logs para melhor rastreabilidade em produção utilizando o `Plug.Logger`.

---

## Tecnologias Utilizadas

- **Elixir**: Linguagem de programação funcional para sistemas distribuídos.
- **Phoenix**: Framework web para aplicações rápidas e escaláveis.
- **PostgreSQL**: Banco de dados relacional.
- **Ecto**: Ferramenta de mapeamento objeto-relacional (ORM).
- **Plug.Logger**: Middleware para geração de logs.
- **Docker**: Ferramenta de containerização para facilitar a execução.

---

## Estrutura do Projeto

```
lib/
├── elixir_cam_api/
│   ├── users/          # Contexto e schema de usuários
│   │   ├── user.ex     # Schema de usuários
│   │   ├── user_context.ex # Contexto de usuários
│   ├── cameras/        # Contexto e schema de câmeras
│   │   ├── camera.ex   # Schema de câmeras
│   │   ├── camera_context.ex # Contexto de câmeras
│   ├── repo.ex         # Configuração do repositório (Ecto)
├── elixir_cam_api_web/
│   ├── controllers/    # Controladores dos endpoints
│   │   ├── user_controller.ex
│   ├── router.ex       # Definição das rotas da API
priv/repo/
├── seeds.exs           # Script para semear o banco de dados
```

---

## Requisitos

- **Elixir**: versão 1.14 ou superior.
- **Phoenix**: versão 1.7 ou superior.
- **PostgreSQL**: versão 14 ou superior.
- **Docker**: Para configurar o ambiente com facilidade.

---

## Instalação e Configuração

### Opção 1: Utilizando **Docker** (Recomendado)

1. **Clone o Repositório**:
    
    ```bash
    git clone https://github.com/seu-usuario/elixir-cam-api.git
    cd elixir-cam-api
    ```
    
2. **Inicie os Containers com Docker Compose**:
    - Este comando subirá o banco de dados PostgreSQL e a aplicação Phoenix:
        
        ```bash
        docker-compose up -d
        ```
        
3. **Acesse a API**:
    - A API estará disponível em: [http://localhost:4000](http://localhost:4000/).
4. **Executar o Seed Regularmente (Opcional)**:
    - Caso precise reinserir os dados de exemplo no banco, utilize:
        
        ```bash
        docker exec -it elixir_cam_api mix run priv/repo/seeds.exs
        ```
        

---

### Opção 2: Instalação Manual

1. **Clone o Repositório**:
    
    ```bash
    git clone https://github.com/seu-usuario/elixir-cam-api.git
    cd elixir-cam-api
    ```
    
2. **Instale as Dependências**:
    - Certifique-se de ter o Elixir, Erlang e Node.js instalados.
    
    ```bash
    mix deps.get
    ```
    
3. **Configuração do Banco de Dados**:
    - Certifique-se de que um banco PostgreSQL esteja rodando e com as credenciais configuradas no `config/dev.exs`:
        - Usuário: `postgres`
        - Senha: `postgres`
        - Banco: `elixir_cam_api_dev`
4. **Inicialize o Banco de Dados e Rode o Seed**:
    - Crie as tabelas e insira os dados iniciais:
    
    ```bash
    mix ecto.setup
    ```
    
5. **Inicie o Servidor**:
    - Inicie a aplicação localmente:
    
    ```bash
    mix phx.server
    ```
    
6. **Acesse a API**:
    - A API estará disponível em: [http://localhost:4000](http://localhost:4000/).

---

### Observações Importantes:

- O script de seed (`priv/repo/seeds.exs`) pode ser executado regularmente para reconfigurar os dados:

```bash
mix run priv/repo/seeds.exs
```

---

## Endpoints Disponíveis

### **GET /api/cameras**

- **Descrição**: Lista usuários e suas câmeras ativas.
- **Filtros Disponíveis**:
    - `camera_name`: Parte do nome da câmera.
    - `camera_brand`: Marca da câmera.
    - `order_by`: Ordenação (`name` ou `brand`).
- **Parâmetros de Paginação**:
    - `page`: Número da página (default: 1).
    - `per_page`: Itens por página (default: 10).

**Exemplo de Resposta**:

```json
{
  "data": [
    {
      "name": "John Doe",
      "email": "john.doe@example.com",
      "deactivated_at": null,
      "cameras": [
        {
          "name": "Camera One",
          "brand": "Hikvision"
        }
      ]
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 10,
    "total_pages": 1,
    "total_entries": 10
  }
}

```

---

### **POST /api/notify-users**

- **Descrição**: Simula o envio de notificações para usuários com câmeras da marca "Hikvision".
- **Resposta**:
    
    ```json
    
    {
      "message": "Notifications sent to users with Hikvision cameras."
    }
    ```
    

---

## Testes

### Como Executar os Testes

Os testes cobrem:

- Paginação e filtros do endpoint `/api/cameras`.
- Simulação de notificações no endpoint `/api/notify-users`.

Execute:

```bash
mix test
```

---

## Detalhes da Implementação

### Decisões Técnicas

- **Uso de RESTful API**: Escolhi uma API RESTful por ser uma solução amplamente adotada e robusta, ideal para integração com SPAs e serviços externos. Ela facilita a manutenção, escalabilidade e a adoção de padrões bem estabelecidos.
- **Seção de Formatação**: A formatação dos dados retornados pelo endpoint `/api/cameras` foi isolada no módulo `ElixirCamApi.Users.Formatter` para garantir coesão e facilitar a manutenção.
- **Separação de Contextos**: Usuários e câmeras possuem seus contextos próprios para facilitar a organização e escalabilidade.
- **CORS**: Configuração básica com o `CorsPlug`, permitindo integração com aplicações frontend.
- **Logs**: O `Plug.Logger` foi utilizado para prover logs padronizados e úteis em produção.
- **Notificações Simuladas**: O envio de notificações utiliza o modo "dev/mailbox" do Swoosh, uma abordagem prática para desenvolvimento local, dispensando configuração de serviços externos.

### Limitações

- **Envio Real de Emails**:
    - A funcionalidade de envio de emails está simulada, utilizando o modo "dev/mailbox" do Swoosh. Em um cenário de produção, seria necessária a configuração de um serviço externo como SMTP, SendGrid ou AWS SES.
- **Autenticação e Autorização**:
    - Não foram implementadas, pois o foco está nos endpoints para consumo por uma aplicação SPA. Essas funcionalidades podem ser adicionadas em uma fase posterior, caso necessário.
- **Logs em JSON**:
    - Embora logs tenham sido configurados com `Plug.Logger` para monitoramento básico, a extensão para logs estruturados em JSON seria uma melhoria para ambientes de produção com alta observabilidade.

---

<p align="center">Feito com 💜  por <a href="[https://github.com/andrevks](https://github.com/andrevks)">André Geraldo</a></p>