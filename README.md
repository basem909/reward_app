
# Reward App

A ruby on rails rewards redemption application that allows users to view available rewards, redeem them using their accumulated points, and track their redemption history. The backend is built with Ruby on Rails and MySQL, with a RESTful API interface. The application features secure authentication using Devise with JWT, comprehensive tests using RSpec, and API documentation via Swagger.

---

## Table of Contents

- [Built With](#built-with)
- [Getting Started](#getting-started)
- [Setup](#setup)
- [Installation](#installation)
- [Usage](#usage)
- [Running Tests](#running-tests)
- [Documentation](#documentation)
- [Authors](#authors)
- [Contributing](#contributing)
- [Show Your Support](#show-your-support)
- [Acknowledgments](#acknowledgments)
- [License](#license)

---

## Built With

- **Ruby on Rails** (API mode, version 7+)
- **MySQL** for the backend database
- **Devise** with **JWT** authentication
- **RSpec** for automated testing
- **RuboCop** for code style enforcement
- **YARD** for inline documentation
- **Swagger (rswag)** for API documentation

---

## Getting Started

Follow these instructions to set up a local copy of the project for development and testing purposes.

### Prerequisites

- **Ruby:** Ensure you have Ruby installed on your machine. See the [official Ruby documentation](https://www.ruby-lang.org/en/documentation/installation/) for details.
- **MySQL:** Install MySQL and configure a user with appropriate privileges. Refer to the [MySQL documentation](https://dev.mysql.com/doc/) for setup instructions.
- **Bundler:** Install bundler if not already installed:
  ```bash
  gem install bundler
  ```

---

## Setup

### Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/yourusername/reward_app.git
cd reward_app
```

### Environment Configuration

1. **Environment Variables:**  
   Create a `.env` file in the project root and set your environment variables. For example:
   ```env
   JWT_SECRET_KEY=your_secret_key_here
   ```
   Adjust the values according to your setup.

2. **Database Configuration:**  
   Update the `config/database.yml` file with the proper credentials for your MySQL database.

---

## Installation

### Backend Installation

1. **Install Dependencies:**
   ```bash
   bundle install
   ```

2. **Database Setup:**
   ```bash
   rails db:create
   rails db:migrate
   ```

## Usage

### Running the Backend

Start the Rails server:

```bash
bin/rails server
```

By default, the backend runs on port 3000. Adjust your port settings in the configuration if needed.

---

## Running Tests

### Backend Tests

Run the RSpec test suite for the backend:

```bash
bundle exec rspec --exclude-pattern "spec/requests/swagger/**/*_spec.rb"
```

For more detailed testing, you can also run:

```bash
bundle exec rspec spec/models
bundle exec rspec spec/requests
```

### Linting and Documentation

- **RuboCop:** Check for code style issues:
  ```bash
  bundle exec rubocop
  ```
- **YARD Documentation:** Generate documentation using YARD:
  ```bash
  yard doc
  ```

---

## Documentation

The API endpoints are documented using Swagger (via rswag). To generate or update the Swagger documentation, run:

```bash
rake rswag:specs:swaggerize
```

This will create or update your Swagger YAML file (located in the `swagger/` directory).

**Video Documentation:**  
A video tutorial/documentation is planned. Once available, update the link below:
- [Video Documentation Part 1](https://www.loom.com/share/c941df4650244d25adf65c3a48198ceb?sid=2c32c86f-ab7d-4f09-9dd9-249b01d4ced4)
- [Video Documentation Part 2](https://www.loom.com/share/2c576a895e8745f3b1264b5da8c56a5a?sid=5e4c7513-e4b0-4dac-9d52-c716b81e4884)

- Take in consideration that to set a user to be admin the record needs to be updated within the console on role col

---

## Authors

👤 **Bassem Shams**

- GitHub: [@basem909](https://github.com/basem909)
- Twitter: [@ShamsBassem](https://twitter.com/ShamsBassem)
- LinkedIn: [Bassem Abdelrahman](https://www.linkedin.com/in/bassem-abdelrahman)

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!  
Feel free to check the [issues page](https://github.com/yourusername/reward_app/issues) for ideas or open a pull request.

---

## Show Your Support

If you like this project, give it a ⭐️!

---

## Acknowledgments

- Thanks to the open-source community for inspiration and support.
- Design inspiration was partly drawn from layouts found in similar projects.

---

## License

This project is [MIT](./MIT.md) licensed.

---

Feel free to modify and expand this README as your project evolves.