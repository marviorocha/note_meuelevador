import { Controller } from "@hotwired/stimulus"
import { liteClient as algoliasearch } from 'algoliasearch/lite';
import instantsearch from 'instantsearch.js';
import {
    searchBox,
    hits,
    pagination,
    refinementList, dynamicWidgets, menu, hierarchicalMenu
} from 'instantsearch.js/es/widgets';

// Connects to data-controller="algolia"
export default class extends Controller {
    static values = {
        appId: String,
        apiKey: String,
        indexName: String
    }

    connect() {
        const searchClient = algoliasearch(this.appIdValue, this.apiKeyValue);

        const search = instantsearch({
            indexName: this.indexNameValue,

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
                    list: 'columns-1 md:columns-2 lg:columns-3 gap-4',
                    item: 'break-inside-avoid mb-4 block',
                },
                templates: {
                    item: `<div class="group card bg-white border border-gray-200 shadow-sm hover:shadow-md transition-shadow duration-300 w-full overflow-hidden">
                    <div class="card-body p-4">
                        {{#tags.length}}
                        <div class="flex flex-wrap gap-1 mb-2">
                            {{#tags}}
                                <span class="badge badge-ghost badge-xs text-[10px] uppercase px-1.5 py-2">
                                   {{name}}
                                </span>
                            {{/tags}}
                        </div>
                        {{/tags.length}}

                        <div class="prose prose-base max-w-none text-gray-800 leading-tight">
                            {{{_highlightResult.content.value}}}
                        </div>

                        <div class="mt-4 pt-2 border-t border-gray-50 flex items-center justify-between   group-hover:opacity-80 transition-opacity duration-200">
                             <span class="badge badge-ghost badge-xs opacity-50">{{status}}</span>
                             <div class="flex gap-1">
                                <a href="/notes/{{objectID}}/edit" data-turbo-frame="modal" class="btn btn-ghost btn-xs text-primary px-1">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-3.5">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
                                    </svg> Editar
                                </a>
                                <a href="/notes/{{objectID}}"


                                   class="btn btn-ghost btn-xs text-info px-1">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                                    </svg> Visualizar

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
