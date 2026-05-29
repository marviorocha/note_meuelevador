import { Controller } from "@hotwired/stimulus"
import { liteClient as algoliasearch } from 'algoliasearch/lite';
import instantsearch from 'instantsearch.js';
import {
    searchBox,
    hits,
    pagination,
    refinementList, dynamicWidgets, menu, hierarchicalMenu
} from 'instantsearch.js/es/widgets';

const searchClient = algoliasearch('JQL57GNACB', 'c20f9d9d5f725912474de47836c3c69e');

// Connects to data-controller="algolia"
export default class extends Controller {
    connect() {
        const search = instantsearch({
            indexName: 'Note',

            searchClient,
            future: {
                preserveSharedStateOnUnmount: true,
            },

            placeholder: 'Pesquisar notas',

        });

        // Adiciona helpers para o template
        search.addWidgets([
            {
                render() {},
                init(options) {
                    options.helper.setQueryParameter('facets', ['*']);
                }
            }
        ]);

        search.on('render', () => {
            // Podemos adicionar transformações de dados aqui se necessário
        });

        search.addWidgets([
            searchBox({
                container: '#searchbox',
                placeholder: 'Pesquisar notas',
                autofocus: true,
                // A configuração de `maxValuesPerFacet` geralmente é feita
                // no widget `configure` para ser aplicada globalmente.
                // Manter aqui funciona, mas pode ser menos explícito.
                // configure: {
                //     maxValuesPerFacet: 1000,
                // },
                cssClasses: {
                    root: 'w-full',
                    form: 'relative',
                    input: 'ais-SearchBox-input input input-md text-white input-bordered w-full ml-2 pl-10', // Padding para os ícones
                    submit: 'btn btn-ghost btn-circle absolute top-1/2 left-2 -translate-y-1/2',
                    reset: 'btn btn-ghost btn-circle absolute top-1/2 right-0 -translate-y-1/2',
                    loadingIndicator: 'absolute top-1/2 right-6 -translate-y-1/2',
                },
                templates: {
                    submit: `
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                    `,
                    reset: `
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    `,
                    loadingIndicator: `<span class="loading loading-spinner loading-sm"></span>`,
                },
            }),
            refinementList({
                container: '#refinement-list',
                attribute: 'category.name',
            }),

            hierarchicalMenu({
                container: '#hierarchical-menu',
                attributes: [
                    'hierarchicalCategories.lvl0',
                    'hierarchicalCategories.lvl1'
                ],
                cssClasses: {
                    list: 'w-full rounded-box',
                    childList: 'ml-0', // Indenta as subcategorias
                    item: 'rounded-lg',
                    link: 'w-full', // Faz o link ocupar toda a largura
                    selectedItem: '', // Usaremos a classe 'active' no link
                    count: 'badge badge-ghost',
                },
                templates: {
                    item: `
                        <a class="flex justify-between {{cssClasses.link}} {{#isRefined}} menu-active text-white bg-slate-500{{/isRefined}}" href="{{url}}">
                            <span class="{{cssClasses.label}} ">{{label}}</span>
                            <span class="{{cssClasses.count}}">
                                {{#helpers.formatNumber}}{{count}}{{/helpers.formatNumber}}
                            </span>
                        </a>
                    `,
                },
                // sortBy: ['isRefined'],
            }),

            pagination({
                container: '#pagination',
                cssClasses: {
                    root: 'join flex justify-center my-4',
                    list: '',
                    item: '',
                    link: 'join-item btn ',
                    selectedItem: 'join-item btn-neutral',
                    disabledItem: 'btn-disabled opacity-50',
                    firstPageItem: 'first:rounded-l',
                    lastPageItem: 'last:rounded-r',
                },
                templates: {
                    previous: '« Voltar',
                    next: 'Próxima »',
                    first: '🏠',
                    last: 'Última Página',
                },
            }),

            hits({
                container: '#hits',
                setSettings: {
                    attributesToSnippet: [
                        'content:10'
                    ]
                },
                cssClasses: {
                    root: 'w-full',
                    list: 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6',
                    item: 'flex', // Faz os cards terem a mesma altura na linha
                },
                templates: {
                    item: `
                <div class="card bg-white border border-gray-200 shadow-sm hover:shadow-md transition-shadow duration-300 w-full flex flex-col">
                    <div class="card-body p-5 flex flex-col h-full">
                        <div class="flex flex-wrap gap-2 mb-3">
                            <span class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Tags:</span>
                            {{#tags}}
                                <a href="#" onclick="document.querySelector('#searchbox input').value = '{{name}}'; document.querySelector('#searchbox input').dispatchEvent(new Event('input')); return false;"
                                   class="badge badge-sm badge-outline hover:bg-slate-800 hover:text-white transition duration-300">
                                   {{name}}
                                </a>
                            {{/tags}}
                        </div>

                        <div class="prose prose-sm text-gray-800 flex-grow mb-4 line-clamp-4">
                            {{{_highlightResult.content.value}}}
                        </div>

                        <div class="mt-auto border-t pt-4">
                            <div class="flex justify-between items-center mb-4">
                                <span class="badge badge-outline badge-sm uppercase">
                                    {{status}}
                                </span>
                            </div>

                            <div class="flex gap-2">
                                <a href="/notes/{{objectID}}/edit" data-turbo-frame="modal" class="btn btn-primary btn-outline btn-sm flex-1">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
                                    </svg>
                                    Editar
                                </a>
                                <a href="/notes/{{objectID}}"
                                   data-turbo-method="delete"
                                   data-turbo-confirm="Deseja realmente deletar essa nota?"
                                   class="btn btn-error btn-outline btn-sm flex-1">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 3.75H6.912a2.25 2.25 0 0 0-2.15 1.588L2.35 13.177a2.25 2.25 0 0 0-.1.661V18a2.25 2.25 0 0 0 2.25 2.25h15A2.25 2.25 0 0 0 21.75 18v-4.162c0-.224-.034-.447-.1-.661L19.24 5.338a2.25 2.25 0 0 0-2.15-1.588H15M2.25 13.5h3.86a2.25 2.25 0 0 1 2.012 1.244l.256.512a2.25 2.25 0 0 0 2.013 1.244h3.218a2.25 2.25 0 0 0 2.013-1.244l.256-.512a2.25 2.25 0 0 1 2.013-1.244h3.859M12 3v8.25m0 0-3-3m3 3 3-3" />
                                    </svg>
                                    Arquivar
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            `,
                },
            }),


        ]);

        search.start();


    }
}
