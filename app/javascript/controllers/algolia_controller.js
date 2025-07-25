import { Controller } from "@hotwired/stimulus"
import { liteClient as algoliasearch } from 'algoliasearch/lite';
import instantsearch from 'instantsearch.js';
import { searchBox, hits, pagination, panel, hierarchicalMenu, } from 'instantsearch.js/es/widgets';

const searchClient = algoliasearch('JQL57GNACB', '104863904eeaada9453cf2d49dcc0bf1');

// Connects to data-controller="algolia"
export default class extends Controller {
    connect() {
        const search = instantsearch({
            indexName: 'Note',
            searchClient,
            placeholder: 'Pesquisar notas',
        });

        search.addWidgets([
            searchBox({
                container: '#searchbox',
                placeholder: 'Pesquisar notas',
                autofocus: true,
                future: {
                    preserveSharedStateOnUnmount: true,
                },
            }),
            hits({
                container: '#hits',
                cssClasses: {
                    item: '',
                },
                templates: {
                    item: `
              <div class="card  w-96 ">
                <div class="card-body text-base-200">
                    <h2 class="card-title font-bold text-2xl text-neutral-600">
                        {{subcategory.category.name}}
                        <h2 class="text-xl  text-neutral-400">
                            {{subcategory.name}}
                        </h2>
                    </h2>
                    <div class="card-actions justify-start pt-2">
                        Tags:
                        {{#tags}}
                        <div class="badge badge-outline cursor-pointer hover:bg-slate-800 hover:text-white transition duration-300">{{name}}</div>
                        {{/tags}}
                    </div>
            
            <p class="prose md:prose-lg text-neutral">{{content}}</p> <p class="prose md:prose-lg text-neutral">{{{_highlightResult.content.value}}}</p>

            <div class="card-footer">
                <small class="text-muted">Criado em: {{created_at}}</small>
            </div>
              <div class="card-actions justify-start pt-2">
              <button class="btn btn-primary">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
                </svg>
                Editar</button>
              <button class="btn btn-error">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M9 3.75H6.912a2.25 2.25 0 0 0-2.15 1.588L2.35 13.177a2.25 2.25 0 0 0-.1.661V18a2.25 2.25 0 0 0 2.25 2.25h15A2.25 2.25 0 0 0 21.75 18v-4.162c0-.224-.034-.447-.1-.661L19.24 5.338a2.25 2.25 0 0 0-2.15-1.588H15M2.25 13.5h3.86a2.25 2.25 0 0 1 2.012 1.244l.256.512a2.25 2.25 0 0 0 2.013 1.244h3.218a2.25 2.25 0 0 0 2.013-1.244l.256-.512a2.25 2.25 0 0 1 2.013-1.244h3.859M12 3v8.25m0 0-3-3m3 3 3-3" />
                </svg>
                Arquivar</button>
            </div>
          </div>
        </div>`,
                },
            }),

        ]);

        search.start();


    }
}
