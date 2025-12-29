FROM ruby:3.2.2

# 必要なパッケージのインストール
RUN apt-get update -qq && apt-get install -y \
  nodejs \
  npm \
  postgresql-client \
  build-essential \
  libpq-dev \
  && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリの設定
WORKDIR /app

# GemfileとGemfile.lockをコピー
COPY Gemfile Gemfile.lock ./

# gemのインストール
RUN bundle install

# アプリケーションのコードをコピー
COPY . .

# ポートの公開
EXPOSE 3000

# サーバーの起動
CMD ["rails", "server", "-b", "0.0.0.0"]
