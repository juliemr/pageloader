/*
 * Copyright 2014 Google Inc. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
library pageloader.test.html;

import 'page_objects.dart';
import 'pageloader_test.dart' as plt;

import 'package:dart.testing/google3_html_config.dart';

import 'package:pageloader/html.dart';
import 'package:unittest/unittest.dart';

import 'dart:html' as html;

void main() {
  useGoogle3HtmlConfiguration();

  setUp(() {
    var body = html.document.getElementsByTagName('body').first;
    const bodyHtml = '''
        <style>
          .class1 { background-color: #00FF00; }
        </style>
        <table id='table1' non-standard='a non standard attr'
            class='class1 class2 class3' style='color: #800080;'>
          <tr>
            <td>r1c1</td>
            <td>r1c2</td>
          </tr>
          <tr>
            <td>r2c1</td>
            <td>r2c2</td>
          </tr>
        </table>
        <div id='div' style='display: none; background-color: red;'>
          some not displayed text</div>
        <input type='text' id='text' />
        <input type='text' readonly id='readonly' disabled />
        <input type='checkbox' class='with-class-test class1 class2' />
        <input type='radio' name='radio' value='radio1' />
        <input type='radio' name='radio' value='radio2' />
        <a href="test.html" id="anchor">test</a>
        <img src="test.png">
        <select id='select1'>
          <option id='option1' value='value 1'>option 1</option>
          <option id='option2' value='value 2'>option 2</option>
        </select>
        <div class="outer-div">
          outer div 1
          <a-custom-tag></a-custom-tag>
        </div>
        <div class="outer-div">
          outer div 2
          <div class="inner-div">
            inner div 1
          </div>
          <div class="inner-div special">
            inner div 2
          </div>
        </div>
        <a-custom-tag id="button-1">
          button 1
        </a-custom-tag>
        <a-custom-tag id="button-2">
          button 2
        </a-custom-tag>''';

    var templateHtml = '<button id="inner">some <content></content></button>';

    var div = new html.DivElement();
    div.setInnerHtml(bodyHtml, validator: new NoOpNodeValidator());

    body.append(div);

    html.document.getElementsByTagName('a-custom-tag').forEach((element) {
      var shadow = element.createShadowRoot();
      shadow.setInnerHtml(templateHtml, validator: new NoOpNodeValidator());
    });
    plt.loader = new HtmlPageLoader(div);

  });

  test('value on text', () {
    var page = plt.loader.getInstance(PageForAttributesTests);
    var handlerCalled = false;
    var node = (page.text as HtmlPageLoaderElement).node as html.InputElement;
    node.onInput.listen((event) {
      handlerCalled = true;
    });
    expect(page.text.attributes['value'], '');
    page.text.type('some text');
    expect(page.text.attributes['value'], 'some text');
    expect(handlerCalled, isTrue);
  });

  plt.runTests();
}

class NoOpNodeValidator implements html.NodeValidator {
  bool allowsAttribute(html.Element element, String attributeName, String value)
      => true;
  bool allowsElement(html.Element element) => true;
}