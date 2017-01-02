
var width = 360,
    height = 360;

var fill = d3.scale.category20();

Shiny.addCustomMessageHandler("for_WordCloud",
function(data){

var predicted_words = [];

    data.forEach(function(row){
        if (100*row.V1 > 0) predicted_words.push({text: row.V3, size: Number(100*row.V1)});
    });
 
    var predicted_words = predicted_words.sort(function(a,b){
        return (a.size < b.size)? 1:(a.size == b.size)? 0:-1
    }).slice(0,100);

    var word_scale = d3.scale.linear()
        .range([15,90])
        .domain([d3.min(predicted_words,function(d) { return d.size; }),
                 d3.max(predicted_words,function(d) { return d.size; })
               ]);

    d3.layout.cloud().size([width, height])
        .words(predicted_words)
        .padding(0)
//      .rotate(function() { return ~~(Math.random() * 2) * 90; })
        .font("Impact")
        .fontSize(function(d) { return word_scale(d.size); })
        .on("end", drawCloud)
        .start();
  

});


function drawCloud(words) {
  d3.select("svg").remove();
    d3.select("#word-cloud").append("svg")
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate("+(width / 2)+","+(height / 2)+")")
    .selectAll("text")
    .data(words)
    .enter().append("text")
    .style("font-size", function(d) { return d.size + "px"; })
    .style("font-family", "Impact")
    .style("fill", function(d, i) { return fill(i); })
    .attr("text-anchor", "middle")
    .attr("transform", function(d) {
        return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
    })
    .text(function(d) { return d.text; });
}
