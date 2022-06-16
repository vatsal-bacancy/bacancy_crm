App.CableManager = {
  refresh() {
    for(let datasetString in App.CableManager.connections) {
      if(App.CableManager.connections.hasOwnProperty(datasetString)) {
        let cableElementDataset = JSON.parse(datasetString);
        let cableElement = $(App.CableManager.utils.elementSelectorByDataset(cableElementDataset));
        if(cableElement.length === 0) {
          App.CableManager.disconnect(cableElementDataset);
        }
      }
    }
    $('[data-cable-manager=true]').each(function() {
      let cableElement = $(this);
      let cableElementDataset = cableElement.data();
      if(!App.CableManager.connected(cableElementDataset)) {
        App.CableManager.connect(cableElementDataset, {
          received(data) {
            cableElement.trigger('cableManager:received', data);
          }
        });
      }
    });
  },
  connected: function(elementDataset) {
    let datasetString = JSON.stringify(elementDataset);
    return !!App.CableManager.connections[datasetString];
  },
  connect: function(elementDataset, callbacks) {
    let datasetString = JSON.stringify(elementDataset);
    let connection = App.cable.subscriptions.create(elementDataset, callbacks);
    App.CableManager.connections[datasetString] = connection;
  },
  disconnect: function(elementDataset) {
    let datasetString = JSON.stringify(elementDataset);
    if(App.CableManager.connections[datasetString]) {
      App.CableManager.connections[datasetString].unsubscribe();
    }
    delete App.CableManager.connections[datasetString];
  },
  connections: {}, // stores element dataset with the connection
  utils: {
    toKebabCase(string) {
      return string
        .match(/[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+/g)
        .map(x => x.toLowerCase())
        .join('-');
    },
    elementSelectorByDataset(dataset) {
      let selector = '';
      for (let key in dataset) {
        if (dataset.hasOwnProperty(key)) {
          selector += `[data-${this.toKebabCase(key)}="${dataset[key]}"]`;
        }
      }
      return selector;
    }
  }
};

$(document).on('turbolinks:load', function () {
  App.CableManager.refresh();
});
