import { Controller } from "@hotwired/stimulus"
import { liteClient as algoliasearch } from 'algoliasearch/lite';
import instantsearch from 'instantsearch.js';
import { searchBox, hits } from 'instantsearch.js/es/widgets';

const searchClient = algoliasearch('JQL57GNACB', '104863904eeaada9453cf2d49dcc0bf1');

// Connects to data-controller="algolia"
export default class extends Controller {
    connect() {
        const search = instantsearch({
            indexName: 'Note',
            searchClient,
        });

        search.addWidgets([
            searchBox({
                container: "#searchbox"
            }),

            hits({
                container: "#hits",
                
            })
        ]);

        search.start();
    }
}
