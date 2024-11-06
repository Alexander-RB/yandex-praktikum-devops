FROM golang:1.22-alpine3.19 as builder
ARG VERSION=${VERSION}
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . /app
RUN go build -o /app /app/...

FROM builder 
ARG VERSION=${VERSION}
WORKDIR /app/
COPY --from=builder /app/api /app/api
ENV BACKEND_PORT=8081
EXPOSE ${BACKEND_PORT}
ENTRYPOINT ["/app/api"]