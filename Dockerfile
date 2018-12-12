###### Stage 1: Push external dependencies ######
FROM maven:3.6.0-jdk-8-slim as push-dependencies-stage
ENV APP_ROOT=/opt/simpleget
ENV M2_ROOT=/root/.m2
WORKDIR ${APP_ROOT}
COPY ./pom.xml ./pom.xml
RUN rm -rf ${M2_ROOT}
RUN mvn -Dcheckstyle.skip verify

###### Stage 2: Build war file ######
FROM maven:3.6.0-jdk-8-slim as build-stage
ENV APP_ROOT=/opt/simpleget
ENV M2_ROOT=/root/.m2 
WORKDIR ${APP_ROOT}
COPY --from=push-dependencies-stage ${M2_ROOT} ${M2_ROOT}
COPY . .
RUN mvn -Dmaven.test.skip=true -Dcheckstyle.skip package

###### Stage 3: Extract war file and run it using payara ######
FROM payara/micro:5.184
ENV WAR_FILE_PATH=/opt/simpleget/target/simple-get.war
COPY --from=build-stage ${WAR_FILE_PATH} ${DEPLOY_DIR}