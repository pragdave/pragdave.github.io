function no_results($ip) {
    let $msg = $("#search-failed");
    $ip.select();
    $ip.focus();
    $("#search-results").hide(200);
    $msg.show(200);
    $ip.on("input", function() {
        console.dir("hiding");
        $msg.hide(200);
        $ip.off("input");
    })
}

function display_results(results) {
    let $results = $("#search-results");
    let $list    = $results.find("ul");

    $("#search-failed").hide(200);

    $list.empty();

    $.each(results, function(n, result) {
        if (n < 10) {
            let $li = $("<li>");
            let $a = $("<a>");
            $a.prop("href", result.path);
            $a.text(result.name);
            $li.append($a);
            $list.append($li);
        }
    });

    $results.show(200);
}

function setButton(text, enabled) {
    $("#search-button")
        .text(text)
        .prop('disabled', !enabled);
}

function do_search(ev) {
    ev.preventDefault();
    ev.stopPropagation();

    setButton("Searching", false);

    var $ip = $("#search-text");
    var drumknott = new Drumknott('pragdave_me');
    drumknott.search({query: $ip.val(), page: 1}, function(data) {
        if (data.total == 0) {
            no_results($ip);
        }
        else {
            display_results(data.results);
        }
        setButton("Search", true);
    });
}

$(function() {
    $('#search-box').on('shown.bs.modal', function () {
        $('#search-text').focus()
    });

    $("#search-form").on("submit", do_search);
});

