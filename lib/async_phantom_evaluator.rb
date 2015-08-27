# encoding: UTF-8
class AsyncPhantomEvaluator < Evaluator
  def evaluate(solution)
    host = ENV['HOSTNAME'] || "http://localhost:3000"
    filename = 'tmp/eval-' + solution.id.to_s + '.js'

    script = %Q[var evaluations = [];
var index = 0;
var exit = false;
var page = require('webpage').create();

/**
 * Wait until the test condition is true or a timeout occurs. Useful for waiting
 * on a server response or for a ui change (fadeIn, etc.) to occur.
 *
 * @param testFx javascript condition that evaluates to a boolean,
 * it can be passed in as a string (e.g.: "1 == 1" or "$('#bar').is(':visible')" or
 * as a callback function.
 * @param onReady what to do when testFx condition is fulfilled,
 * it can be passed in as a string (e.g.: "1 == 1" or "$('#bar').is(':visible')" or
 * as a callback function.
 * @param timeOutMillis the max amount of time to wait. If not specified, 3 sec is used.
 */
function waitFor(testFx, onReady, msg, timeOutMillis) {
    var maxtimeOutMillis = timeOutMillis ? timeOutMillis : 3000, //< Default Max Timout is 3s
    start = new Date().getTime(),
    condition = false,
    interval = setInterval(function() {
      if ( (new Date().getTime() - start < maxtimeOutMillis) && !condition ) {
        // if not time-out yet and condition not yet fulfilled
        condition = (typeof(testFx) === "string" ? eval(testFx) : testFx()); //< defensive code
      } else {
        if(!condition) {
          // if condition still not fulfilled (timeout but condition is 'false')
          chain.fail(msg);
        } else {
          // condition fulfilled (timeout and/or condition is 'true')
          typeof(onReady) === "string" ? eval(onReady) : onReady(); //< Do what it's supposed to do once the condition is fulfilled
          clearInterval(interval); //< Stop this interval
        }
      }
    }, 250); //< repeat check every 250ms
};

function open(path, callback, viewportSize) {
  evaluations.push({ path: path, callback: callback, viewportSize: viewportSize });
}

var chain = {
  fail: function(message) {
    exit = true;
    console.log(message);
    exitPhantom();
  },

  continue: function() {
    if (exit) return;
    index++;
    if (index >= evaluations.length) {
      exitPhantom();
    } else {
      // the timeout allows the 'page.open' method inside 'evaluate' to finish
      setTimeout(function() { 
        var evaluation = evaluations[index];
        evaluate(evaluation);
      }, 100);
    }
  }
};

function exitPhantom() {
  if (page) page.close();
  setTimeout(function(){ phantom.exit(); }, 0);
}

function evaluate(evaluation) {
  if (!evaluation) {
    return;
  }

  page.viewportSize = evaluation.viewportSize || { width: 1024, height: 800 };
  var url = '#{host}/solutions/#{solution.id}/preview/' + evaluation.path;
  page.open(url, function(status) {
    if (status != 'success') {
      console.log('No se pudo abrir ' + evaluation.path);
      return;
    }

    page.injectJs('lib/phantom-util.js');
    evaluation.callback(page, chain);
  });
}

page.onError = function(msg, trace) {
  console.error(msg);
  exitPhantom();
};

    ]

    File.open(filename, 'w') do |f|
      f.write script + "\n"
      f.write solution.challenge.evaluation + "\n"
      f.write "evaluate(evaluations[0]);"
    end

    output = Phantomjs.run(filename)
    output.blank? ? complete(solution) : fail(solution, output)

  rescue Exception => e
    puts e.message
    puts e.backtrace

    fail(solution, "Hemos encontrado un error en el evaluador, favor reportar a info@makeitreal.camp: #{e.message}")
  end
end