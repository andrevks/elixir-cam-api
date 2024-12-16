# Use the official Elixir image
FROM elixir:1.14.5-alpine

# Install necessary tools
RUN apk add --no-cache build-base git

# Set the working directory
WORKDIR /app

# Install Hex and Rebar
RUN mix local.hex --force && mix local.rebar --force

# Copy mix files and fetch dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

# Copy application files
COPY . .

# Compile the application
RUN mix compile

# Expose the app port
EXPOSE 4000

# Set default environment
ENV MIX_ENV=prod

# Start the application
CMD ["mix", "phx.server"]
