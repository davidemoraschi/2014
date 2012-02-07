var query1, visualization1;
var query2, visualization2;
var query3, visualization3;
var query4, visualization4;

function initialize() {
    visualization1 = new google.visualization.Table(document.getElementById('visualization1'));
    query1 = new google.visualization.Query('http://fraterno.valme.net/cdm_dad/gdatasource2.get_json?p_datasource_id=dae');
    query1.setRefreshInterval(20);
    query1.send(drawVisualization1);

    visualization2 = new google.visualization.LineChart(document.getElementById('visualization2'));
    query2 = new google.visualization.Query('http://fraterno.valme.net/cdm_dad/gdatasource2.get_json?p_datasource_id=dae_hist');
    query2.setRefreshInterval(20);
    query2.send(drawVisualization2);

    visualization3 = new google.visualization.BarChart(document.getElementById('visualization3'));
    query3 = new google.visualization.Query('http://fraterno.valme.net/cdm_dad/gdatasource2.get_json?p_datasource_id=dae');
    query3.setRefreshInterval(20);
    query3.send(drawVisualization3);

    visualization4 = new google.visualization.Map(document.getElementById('visualization4'));
    query4 = new google.visualization.Query('http://fraterno.valme.net/cdm_dad/gdatasource2.get_json?p_datasource_id=addr');
    query4.setRefreshInterval(60);
    query4.send(drawVisualization4);

//    visualization5 = new google.visualization.Table(document.getElementById('visualization5'));
//    query4 = new google.visualization.Query('http://fraterno.valme.net/cdm_dad/gdatasource2.get_json?p_datasource_id=obj');
//    query4.setRefreshInterval(1);
//    query4.send(drawVisualization5);
}

function drawVisualization1(response) {
    if (response.isError()) {
        alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
        return;
    }
    var TcssClassNames = { headerRow: 'th', tableRow: 'tic', oddTableRow: 'tac', hoverTableRow: 'toc', selectedTableRow: 'toc' };
    var Tdata = new google.visualization.DataTable();
    Tdata = response.getDataTable();
    visualization1.draw(Tdata,
        {
            height: 300, width: screen.width / 100 * 44,
            allowHtml: true, cssClassNames: TcssClassNames,
            page: 'enable', pageSize: 10
        });
}

function drawVisualization2(response) {
    if (response.isError()) {
        alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
        return;
    }
    var Tdata = new google.visualization.DataTable();
    Tdata = response.getDataTable();
    visualization2.draw(Tdata,
        {
            legend: 'top', height: 300, width: screen.width / 100 * 44,
            title: 'Datos de la última semana', legend: 'top',
            colors: ['#FF9966', '#0099CC']
        });
}

function drawVisualization3(response) {
    if (response.isError()) {
        alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
        return;
    }
    var Tdata = new google.visualization.DataTable();
    Tdata = response.getDataTable();
    visualization3.draw(Tdata,
        {
            height: 300, width: screen.width / 100 * 44,
            title: 'Datos a partir de las 00:00h de hoy', legend: 'top',
            colors: ['#FF9966', '#0099CC'],
            isStacked: true 
        });
}

function drawVisualization4(response) {
    if (response.isError()) {
        alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
        return;
    }
    var Tdata = new google.visualization.DataTable();
    Tdata = response.getDataTable();
    visualization4.draw(Tdata,
        {
            //height: 300, width: screen.width / 100 * 44,
            mapType: 'terrain', showTip: true 
        });
}

//function drawVisualization5(response) {
//    if (response.isError()) {
//        alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
//        return;
//    }
//    visualization5.draw(response.getDataTable(), { });
//}
