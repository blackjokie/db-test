FROM golang:1.19-alpine3.17 as builder

ARG GO_BUILD_COMMAND="go build -tags static_all"

# this command if you get source from bitbucket repos
# Create the directory where the application will reside
RUN mkdir -p /go/src/testing/db-test

WORKDIR /go/src/testing/db-test

COPY . .

# application builder step
RUN go mod tidy && go mod download && go mod vendor
RUN eval $GO_BUILD_COMMAND


# STEP 2 build a small image
# Set up the final (deployable/runtime) image.
FROM alpine:3.17

# setup package dependencies
RUN apk --no-cache update && apk --no-cache add bash 

ENV BUILDDIR=/go/src/testing/db-test
ENV PROJECT_DIR=/opt/db-test

# Setting timezone
ENV TZ=Asia/Jakarta
RUN apk add --no-cache -U tzdata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#create project directory
RUN mkdir -p $PROJECT_DIR

WORKDIR $PROJECT_DIR

COPY --from=builder $BUILDDIR/main db-test

CMD ["sh","-c", "/opt/db-test/db-test"]
