FROM gcr.io/dataflow-templates-base/java11-template-launcher-base

ARG WORKDIR=/dataflow/template
RUN mkdir -p ${WORKDIR}
WORKDIR ${WORKDIR}

COPY target/myapp-1.0.jar .

ENV FLEX_TEMPLATE_JAVA_MAIN_CLASS="com.example.App"
ENV FLEX_TEMPLATE_JAVA_CLASSPATH="${WORKDIR}/*"

ENTRYPOINT ["/opt/google/dataflow/java_template_launcher"]