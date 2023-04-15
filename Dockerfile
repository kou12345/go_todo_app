# デプロイ用コンテナに含めるバイナリを作成するコンテナ
FROM golang:1.20.3-bullseye AS deploy-builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -trimpath -ldflags "-w -s" -o app

# ----------------------------------------

# デプロイ用コンテナ
FROM debian:bullseye-slim AS deploy

RUN apt-get update

COPY --from=deploy-builder /app/app .

# appバイナリを実行
CMD ["./app"]

# ----------------------------------------

# ローカル環境開発で利用するホットリロード環境
FROM golang:1.20.3-bullseye AS dev

WORKDIR /app

RUN go install github.com/cosmtrek/air@latest
CMD [ "air" ]