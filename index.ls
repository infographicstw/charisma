angular.module \main, <[]>
  ..controller \main, <[$scope $http]> ++ ($scope, $http) ->
    plotdb.load \chart/charisma.json, (chart) -> $scope.$apply ->
      $scope.chart = chart
      $scope.fetch!
    $scope.fetch = ->
      url = <[
        https://spreadsheets.google.com/feeds/list/
        16fmW_tXYocbRe6oASbemINxF1nJ9ECYRU4gZiHdXF5g
        /2/public/values?alt=json
      ]>.join("")
      $http do
        url: url
        method: \GET
      .success (d) ->
        result = []
        for item in d.feed.entry =>
          hash = {}
          [k for k of item].filter(->/^gsx\$/.exec(k)).map(->
            ret = /^(\d)\./.exec(item[it].$t)
            if !ret => return
            v = ret.1
            hash[v] = (hash[v] or 0) + 1
          )
          result.push do
            gender: item["gsx$我的性別"].$t
            name: item["gsx$我的名字"].$t
            wisdom: hash["1"]
            passion: hash["2"]
            instinct: hash["3"]
        console.log "#{result.length} entries fetched"
        fields = do
          name: [{name: "name", data: result.map(->it.name)}]
          category: [{name: "gender", data: result.map(->it.gender)}]
          value1: [{name: "wisdom", data: result.map(->it.wisdom)}]
          value2: [{name: "passion", data: result.map(->it.passion)}]
          value3: [{name: "instinct", data: result.map(->it.instinct)}]
        $scope.chart.config {}
        $scope.chart.data fields
        $scope.chart.attach document.getElementById(\ternary)
      .error (d) ->
    $scope.root = d3.select \#ternary
    $scope.set-active = ->
      $scope.root.selectAll \circle .attr do
        display: -> 
          if !$scope.active or it.category == <[全部 男 女 其它]>[$scope.active] => return "block"
          return "none"
    $scope.$watch 'active', -> $scope.set-active!
    $scope.search = ->
      $scope.root.selectAll \circle .attr do
        display: ->
          if it.name.indexOf($scope.name) >= 0 => return "block"
          return "none"
    $scope.clear = -> $scope.set-active!
    $scope.refresh = -> $scope.fetch!
