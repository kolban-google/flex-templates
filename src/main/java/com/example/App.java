// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

package com.example;

import java.util.Arrays;

import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.options.Default;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.options.StreamingOptions;
import org.apache.beam.sdk.transforms.Create;
import org.apache.beam.sdk.transforms.MapElements;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.TypeDescriptors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class App {

  private static final Logger LOG = LoggerFactory.getLogger(App.class);

  public interface Options extends StreamingOptions {
    @Description("Input text to print.")
    @Default.String("My input text")
    String getInputText();
    void setInputText(String value);
  }

  public static PCollection<String> buildPipeline(Pipeline pipeline, String inputText) {
    return pipeline
        .apply("Create elements", Create.of(Arrays.asList("Hello", "World!", inputText)))
        .apply("Print elements",
            MapElements.into(TypeDescriptors.strings()).via(x -> {
              LOG.info(x);
              return x;
            }));
  }

  public static void main(String[] args) {
    var options = PipelineOptionsFactory.fromArgs(args).withValidation().as(Options.class);
    var pipeline = Pipeline.create(options);
    App.buildPipeline(pipeline, options.getInputText());
    pipeline.run();
  }
}