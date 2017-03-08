FROM buildpack-deps:xenial

RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb
RUN apt-get update
RUN apt-get install -y esl-erlang=1:19.2.3 elixir=1.3.4-1 ruby-full

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

ADD . /app
WORKDIR /app
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix compile
RUN gem install foreman
CMD foreman run mix ecto.setup && \
    foreman start -f Procfile.dev
