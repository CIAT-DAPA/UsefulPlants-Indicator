

    google.charts.load('current', { 'packages': ['geochart'] });
    google.charts.load('current', { packages: ['corechart', 'bar'] });

    var font_name = 'Open Sans';
    var font_size = 12;
    var number_format = '##0.0'


    google.charts.setOnLoadCallback(drawGlobal);

    function drawGlobal() {
        var gdata = google.visualization.arrayToDataTable(global);


        var formatter = new google.visualization.NumberFormat(
            { pattern: number_format });

        formatter.format(gdata, 1);
        formatter.format(gdata, 3);
        formatter.format(gdata, 5);

        var options = {
            legend: { position: "bottom", maxLines: 3, textStyle: { fontName: font_name, fontSize: font_size } },
            tooltip: { textStyle: { fontName: font_name, fontSize: font_size } },
            colors: [color_green, color_yellow, color_red],
            bar: { groupWidth: "90%" },
            chartArea: { 'width': '70%', 'height': '45%' },
            vAxis: { textStyle: { color: 'black', fontName: font_name, fontSize: font_size, bold: false, italic: true } },
            hAxis: {
                textStyle: { color: 'black', fontName: font_name, fontSize: font_size, bold: false, italic: true },
                title: 'Proportion of species (%)',
                maxValue: 100,
                titleTextStyle: { color: 'black', fontName: font_name, fontSize: font_size, bold: false, italic: true }
            },
            isStacked: 'true'
        };

        var chart = new google.visualization.BarChart(document.getElementById('bar_global_div'));
        chart.draw(gdata, options);
    }


    google.charts.setOnLoadCallback(drawCountriesMap);

    function drawCountriesMap() {
        var gdata = google.visualization.arrayToDataTable(countries_mean);

        var formatter = new google.visualization.NumberFormat(
            { pattern: number_format });

        formatter.format(gdata, 2);


        var options = {
            resolution: 'country',
            legend: { textStyle: { fontName: font_name } },
            tooltip: { textStyle: { fontName: font_name, fontSize: font_size } },
            colors: [color_red, color_yellow, color_green_soft, color_green]
        };

        var chart = new google.visualization.GeoChart(document.getElementById('countries_mean_div'));

        chart.draw(gdata, options);
    }

    google.charts.setOnLoadCallback(drawCountriesInSituMap);

    function drawCountriesInSituMap() {
        var gdata = google.visualization.arrayToDataTable(countries_insitu);

        var formatter = new google.visualization.NumberFormat(
            { pattern: number_format });

        formatter.format(gdata, 2);

        var options = {
            resolution: 'country',
            legend: { textStyle: { fontName: font_name } },
            tooltip: { textStyle: { fontName: font_name, fontSize: font_size } },
            colors: [color_red, color_yellow, color_green_soft, color_green]
        };

        var chart = new google.visualization.GeoChart(document.getElementById('countries_insitu_div'));

        chart.draw(gdata, options);
    }

    google.charts.setOnLoadCallback(drawCountriesExSituMap);

    function drawCountriesExSituMap() {
        var gdata = google.visualization.arrayToDataTable(countries_exsitu);

        var formatter = new google.visualization.NumberFormat(
            { pattern: number_format });

        formatter.format(gdata, 2);

        var options = {
            resolution: 'country',
            legend: { textStyle: { fontName: font_name } },
            tooltip: { textStyle: { fontName: font_name, fontSize: font_size } },
            colors: [color_red, color_yellow, color_green_soft, color_green]
        };

        var chart = new google.visualization.GeoChart(document.getElementById('countries_exsitu_div'));

        chart.draw(gdata, options);
    }


    google.charts.setOnLoadCallback(drawUses);

    function drawUses() {
        var gdata = google.visualization.arrayToDataTable(uses_comb);

        var formatter = new google.visualization.NumberFormat(
            { pattern: number_format });

        formatter.format(gdata, 1);
        formatter.format(gdata, 3);
        formatter.format(gdata, 5);

        var options = {
            legend: { position: "bottom", maxLines: 3, textStyle: { fontName: font_name, fontSize: font_size } },
            tooltip: { textStyle: { fontName: font_name, fontSize: font_size } },
            colors: [color_green, color_yellow, color_red],
            chartArea: { 'width': '70%', 'height': '90%' },
            bar: { groupWidth: "90%" },
            vAxis: { textStyle: { color: 'black', fontName: font_name, fontSize: font_size, bold: false, italic: true } },
            hAxis: {
                textStyle: { color: 'black', fontName: font_name, fontSize: font_size, bold: false, italic: true },
                title: 'Proportion of species (%)',
                titleTextStyle: { color: 'black', fontName: font_name, fontSize: font_size, bold: false, italic: true }
            },
            isStacked: 'true'
        };

        var chart = new google.visualization.BarChart(document.getElementById('bar_uses_div'));
        chart.draw(gdata, options);
    }

    google.charts.setOnLoadCallback(drawRegions);

    function drawRegions() {
        var gdata = google.visualization.arrayToDataTable(regions_comb);

        var formatter = new google.visualization.NumberFormat(
            { pattern: number_format });

        formatter.format(gdata, 1);
        formatter.format(gdata, 3);
        formatter.format(gdata, 5);

        var options = {
            legend: { position: "bottom", maxLines: 3, textStyle: { fontName: font_name, fontSize: font_size } },
            tooltip: { textStyle: { fontName: font_name, fontSize: font_size } },
            colors: [color_green, color_yellow, color_red],
            bar: { groupWidth: "100%" },
            chartArea: { 'width': '65%', 'height': '90%' },
            vAxis: { textStyle: { color: 'black', fontName: font_name, fontSize: font_size, bold: false, italic: true } },
            hAxis: {
                textStyle: { color: 'black', fontName: font_name, fontSize: font_size, bold: false, italic: true },
                title: 'Proportion of species (%)',
                titleTextStyle: { color: 'black', fontName: font_name, fontSize: font_size, bold: false, italic: true }
            },
            isStacked: 'true'
        };

        var chart = new google.visualization.BarChart(document.getElementById('bar_regions_div'));
        chart.draw(gdata, options);
    }


    google.charts.setOnLoadCallback(drawCountriesTaxaMap);

    function drawCountriesTaxaMap() {
        var gdata = google.visualization.arrayToDataTable(countries_taxa);

        var formatter = new google.visualization.NumberFormat(
            { pattern: '###0' });

        formatter.format(gdata, 2);

        var options = {
            resolution: 'country',
            legend: { textStyle: { fontName: font_name } },
            tooltip: { textStyle: { fontName: font_name, fontSize: font_size } },
            colors: [color_green_soft, color_green]
        };

        var chart = new google.visualization.GeoChart(document.getElementById('countries_taxa_div'));

        chart.draw(gdata, options);
    }




    function drawSpeciesTable() {

        var table = $('#species_table').DataTable({
            data: species,
            responsive: true,
            columns: [

                { title: "Taxon key", searchable: false, visible: false },
                { title: "Scientific Name" },
                { title: "Total records", searchable: false },
                { title: "G records", searchable: false },
                { title: "H records", searchable: false },
                { title: "Model", searchable: false, visible: false },
                { title: "Indicator <br> (<i>ex situ</i>)", searchable: false, render: $.fn.dataTable.render.number( ',', '.', 1, '' ) },
                { title: "Indicator <br> (<i>in situ</i>)", searchable: false, render: $.fn.dataTable.render.number( ',', '.', 1, '' ) },
                { title: "Indicator <br> (combined)", searchable: false, render: $.fn.dataTable.render.number( ',', '.', 1, '' ) },
                { title: "Priority category", searchable: false }
            ]
        });


    }

    $(document).ready(function () {
        drawSpeciesTable();
    });



    $(document).ready(function () {
        $(window).resize(function () {
            drawGlobal();
            drawCountriesMap();
            drawCountriesInSituMap();
            drawCountriesExSituMap();
            drawUses();
            drawRegions();
            drawCountriesTaxaMap();
        });
    });

