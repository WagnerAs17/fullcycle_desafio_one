FROM golang:1.17-alpine as build
WORKDIR /app
COPY /app ./
RUN go build -o /godocker

FROM scratch
WORKDIR /
COPY --from=build /godocker /godocker
ENTRYPOINT [ "/godocker" ]