FROM bitwalker/alpine-elixir-phoenix:latest

# Set exposed ports
EXPOSE 5000
ENV PORT=5000 MIX_ENV=prod
ENV SECRET_KEY_BASE=65vTUkHROnS3rljrPRe4CTFuK0KZfF/AecuSTYNc1fh/os+SZHVlJjWTs5EwHLSR
ENV DATABASE_URL=postgres://doadmin:929G89DVkXkadMe6@db-postgresql-ams3-do-user-8500484-0.b.db.ondigitalocean.com:25060/SenderSupportDB

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# Same with npm deps
ADD assets/package.json assets/
RUN cd assets && \
    npm install

ADD . .

# Run frontend build, compile, and digest assets
RUN cd assets/ && \
    npm run deploy && \
    cd - && \
    mix do compile, phx.digest

USER default

CMD ["mix", "phx.server"]