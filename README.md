# Pin People – Tech Challenge

This project was developed as part of the Pin People Tech Challenge with the following main goals:

* Provide a functional solution to some of the proposed challenges;
* Demonstrate proficiency in [Ruby on Rails](https://rubyonrails.org/) and other relevant technologies;
* Follow best practices regarding code organization, testing, containerization, and data handling.

---

## Technologies Used

* [Ruby 3.3.6](https://www.ruby-lang.org/en/)
* [Rails 8.0.2](https://rubyonrails.org/)
* [PostgreSQL](https://www.postgresql.org/)
* [Chart.js](https://www.chartjs.org/)

Additional gems:

* [Sidekiq](https://sidekiq.org/) – Background job processing
* [Kaminari](https://github.com/kaminari/kaminari) – API pagination
* [Ransack](https://github.com/activerecord-hackery/ransack) – Filtering support
* [Byebug](https://github.com/deivid-rodriguez/byebug) – Debugging tool
* [RSpec Rails](https://github.com/rspec/rspec-rails) – Testing framework
* [FactoryBot Rails](https://github.com/thoughtbot/factory_bot_rails) – Factories for RSpec
* [Faker](https://github.com/faker-ruby/faker) – Generating fake data in factories
* [Rails Controller Testing](https://github.com/rails/rails-controller-testing) – Controller specs support
* [Shoulda Matchers](https://github.com/thoughtbot/shoulda-matchers) – Simplified matchers for RSpec

---

## Completed Tasks

Below is the list of proposed tasks. The ones completed in this project are marked:

1. [x] **Create a Basic Database**
   The database was modeled using [PostgreSQL](https://www.postgresql.org/) with a simple and normalized structure. Migrations were used to create tables and define constraints. Business rules were enforced through model validations, associations, scopes, callbacks, and custom methods. You can view the schema structure in the [database.svg](./database.svg) file.

It consists of three main entities:

* `User`: represents the respondent of a survey, associated with a company and department;
* `SurveyResponse`: holds a fixed structure of survey data (based on the CSV format);
* `Department`: represents organizational areas. It is self-referential, allowing nested hierarchies without requiring multiple models for company/department abstraction.

2. [x] **Create a Basic Dashboard**
   Accessible via the left menu under "Dashboard". It displays three different types of charts with distinct insights.

3. [x] **Create a Test Suite**
   RSpec tests were written for all Ruby files containing business logic, including models, services, and jobs.

4. [x] **Create a Docker Compose Setup**
   The app is fully containerized using Docker and Docker Compose for easy setup and deployment.

5. [x] **Perform Exploratory Data Analysis (EDA)**
   Accessible via the "Análise Exploratória" section. It includes three different data insights, two of which are visualized as charts.

6. [x] **Data Visualization – Company Level**
   Accessible from the "Dados da Empresa" menu. Displays two charts with aggregated insights related to the company.

7. [x] **Data Visualization – Area Level**
   Accessible from the "Dados da Área" menu. Contains a graph comparing promoters vs. detractors across departments.

8. [x] **Data Visualization – Employee Level**
   Accessible from the "Dados do Usuário" menu. Includes a sortable, filterable table showing user data along with eNPS and satisfaction averages from their departments.

9. [x] **Build a Simple API**
   A RESTful API was developed for CRUD operations on users, departments, and survey responses. The data exploration and visual dashboards are not exposed through the API. The API documentation is available in the root directory as: `pin-people-api.postman_collection.json`

10. [ ] **Sentiment Analysis**
    This item was not implemented.

11. [x] **Report Generation**
    Although not explicitly implemented, most data is displayed via graphs and tables that can be interpreted as reporting outputs.

12. [ ] **Creative Exploration**
    This item was not implemented.

---

## Requirements

This project runs via Docker. Ensure the following tools are installed:

* [Docker](https://docs.docker.com/) (version 20.10 or higher)
* [Docker Compose](https://docs.docker.com/compose/) (version 2.0 or higher)

> **Note:** Tested on **macOS** with:
>
> * Docker: `27.3.1 (build ce1223035a)`
> * Docker Compose: `v2.31.0-desktop.2`

---

## Running and Using the Project

### 1. Start the application

```bash
docker-compose up --build
```

### 2. Seed the database

```bash
docker-compose exec web rails db:seed
```

### 3. Access via browser

Go to: `http://localhost:3000`

### 4. Run the specs

```bash
docker-compose exec web bundle exec rspec spec/models
```

### 5. API testing via Postman

Import the Postman collection in the root directory:

> `pin-people-api.postman_collection.json`

---

## Future Improvements / Missing Items

* Add i18n support for internationalization of frontend labels, validation messages, and controller responses;
* Refactor JavaScript code by moving chart configurations into separate files and modularizing stylesheets;
* Improve validation and handling of multi-valued or inconsistent fields (e.g., cities could be validated using a locale file or external API);
* Handle empty states and loading indicators better in the UI;
* Make the survey model dynamic to allow different question structures or formats beyond the initial CSV-based static layout.
