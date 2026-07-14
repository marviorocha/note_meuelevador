import { Controller } from "@hotwired/stimulus"
import TypesenseInstantSearchAdapter from "typesense-instantsearch-adapter"
import instantsearch from "instantsearch.js"
import {
  searchBox,
  hits,
  pagination,
  refinementList,
  clearRefinements,
  currentRefinements,
  stats,
  configure,
} from "instantsearch.js/es/widgets"

// Connects to data-controller="typesense"
export default class extends Controller {
  static values = {
    host: String,
    apiKey: String,
    protocol: { type: String, default: "https" },
    port: { type: Number, default: 8108 },
  }

  connect() {
    const host   = document.querySelector('meta[name="typesense-host"]')?.content
                   || this.hostValue
    const apiKey = document.querySelector('meta[name="typesense-search-key"]')?.content
                   || this.apiKeyValue

    if (!host || !apiKey) {
      console.warn("Typesense: host ou search key não configurados.")
      return
    }


    const typesenseAdapter = new TypesenseInstantSearchAdapter({
      server: {
        apiKey,
        nodes: [{ host, port: this.portValue, protocol: this.protocolValue }],
        cacheSearchResultsForSeconds: 2 * 60,
      },
      additionalSearchParameters: {
        query_by: "content,author.name,category.name,subcategory.name,tags",
        highlight_full_fields: "content",
        snippet_threshold: 10,
        num_typos: 1,
      },
    })

    const search = instantsearch({
      indexName: "notes",
      searchClient: typesenseAdapter.searchClient,
      future: {
        preserveSharedStateOnUnmount: true,
      },
    })

    search.addWidgets([
      configure({
        hitsPerPage: 20,
      }),

      searchBox({
        container: "#ais-searchbox",
        placeholder: "Pesquisar notas...",
        autofocus: true,
        cssClasses: {
          root: "w-full",
          form: "relative flex items-center",
          input:
            "input input-bordered input-lg   pr-10 w-[730px] focus:outline-none",
          submit: "absolute right-10 top-1/2 -translate-y-1/2 btn btn-ghost btn-xs p-1",
          reset: "absolute right-2 top-1/2 -translate-y-1/2 btn btn-ghost btn-xs p-1",
          loadingIndicator: "absolute right-20 top-1/2 -translate-y-1/2",
        },
        templates: {
          submit({ cssClasses }, { html }) {
            return html`<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>`
          },
          reset({ cssClasses }, { html }) {
            return html`<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>`
          },
          loadingIndicator({ cssClasses }, { html }) {
            return html`<span class="loading loading-spinner loading-sm"></span>`
          },
        },
      }),

      stats({
        container: "#ais-stats",
        templates: {
          text({ nbHits, processingTimeMS }, { html }) {
            return html`<span class="text-lg text-gray-600">${nbHits} nota${nbHits !== 1 ? "s" : ""} encontrada${nbHits !== 1 ? "s" : ""} em ${processingTimeMS}ms</span>`
          },
        },
      }),

      refinementList({
        container: "#ais-category-filter",
        attribute: "category.name",
        sortBy: ["name:asc"],
        cssClasses: {
          root: "w-full",
          list: "text-normal text-gray-600  rounded-box p-2",
          item: "rounded",
          selectedItem: "font-semibold",
          label: "w-full cursor-pointer px-16",
          checkbox: "hidden",
          count: "badge  badge-sm badge-ghost ml-auto",
          showMore: "btn btn-wide btn-sm  my-1 w-full [&.ais-RefinementList-showMore--disabled]:bg-gray-200 [&.ais-RefinementList-showMore--disabled]:text-gray-500 [&.ais-RefinementList-showMore--disabled]:cursor-not-allowed",
        },
        templates: {
          item({ label, count, isRefined }, { html }) {
            return html`
              <span class="flex justify-between items-center  w-full ${isRefined ? "font-semibold text-info" : ""}">

                <span class="flex items-center gap-2 py-1 cursor-pointer">
                  <input type="checkbox" checked="${isRefined ? "checked" : ""}" class="checkbox checkbox-info" /> ${label}
                </span>
                <span class="badge badge-sm badge-ghost">${count}</span>
              </span>
            `
          },
            showMoreText({ isShowingMore }, { html }) {
            return html`${isShowingMore ? 'Mostrar menos' : 'Mostrar mais'}`;
            },
        },
        showMore: true,
        limit: 10,
        showMoreLimit: 50,
      }),

      refinementList({
        container: "#ais-subcategory-filter",
        attribute: "subcategory.name",
        sortBy: ["name:asc"],
        cssClasses: {
          root: "w-full",
          list: "text-normal text-gray-600  rounded-box p-2 ",
          item: "rounded ",
          selectedItem: "font-semibold ",
          label: "flex text-xl justify-between cursor-pointer",
          checkbox: "hidden",
          count: " ml-auto",
          showMore: "btn btn-wide btn-sm  my-1 w-full [&.ais-RefinementList-showMore--disabled]:bg-gray-200 [&.ais-RefinementList-showMore--disabled]:text-gray-500 [&.ais-RefinementList-showMore--disabled]:cursor-not-allowed",
        },
        templates: {
          item({ label, count, isRefined }, { html }) {
            return html`
              <span class="flex  justify-between w-full ${isRefined ? "font-semibold text-info" : ""}">
                <span class="flex items-center gap-2 py-1 cursor-pointer">
                  <input type="checkbox" checked="${isRefined ? "checked" : ""}" class="checkbox checkbox-info" /> ${label}
                </span>
                <span class="badge">${count}</span>
              </span>
            `
          },
          showMoreText({ isShowingMore }, { html }) {
            return html`${isShowingMore ? 'Mostrar menos' : 'Mostrar mais'}`;
            },
        },
        showMore: true,
        limit: 15,
        showMoreLimit: 100,
      }),

      clearRefinements({
        container: "#ais-clear-refinements",
        cssClasses: {
          button: " w-full mt-2",
          disabledButton: "hidden",
        },
        templates: {
          resetLabel({ hasRefinements }, { html }) {
                return html`<div class="filter">
                    <input class="btn btn-md mx-2" type="radio" name="metaframeworks" aria-label="Limpar filtros"/>

                    </div>`
          },
        },
      }),

      hits({
        container: "#ais-hits",
        cssClasses: {
          root: "w-full",
          list: "columns-1 md:columns-2 lg:columns-3 gap-4",
          item: "break-inside-avoid mb-4 block p-0 border-0 shadow-none",
        },
        templates: {
          item(hit, { html, components }) {
            const editUrl = `/notes/${hit.objectID}/edit`
            const tags = Array.isArray(hit.tags) ? hit.tags : []

            return html`
              <div class="group card bg-white border border-gray-200 shadow-sm hover:shadow-md transition-shadow duration-300 w-full overflow-hidden">
                <div class="card-body p-4">

                  <div class="prose prose-xl max-w-none text-gray-800 leading-tight">
                    ${components.Highlight({ hit, attribute: "content" })}
                  </div>

                  <div class="mt-4 pt-2 border-t border-gray-30 flex-wrap flex items-center justify-between group-hover:opacity-80 transition-opacity duration-200">
                    ${tags.length > 0 ? html`
                    <div class="flex flex-wrap gap-1 mb-2">
                      ${tags.map(tag => html`
                        <button
                          onclick=${(e) => {
                            e.preventDefault()
                            const input = document.querySelector("#ais-searchbox input")
                            if (input) {
                              input.value = tag
                              input.dispatchEvent(new Event("input", { bubbles: true }))
                            }
                          }}
                          class="text-blue-600 hover:text-blue-700 px-2 py-1 hover:bg-blue-100 border border-blue-500 rounded transition duration-300 cursor-pointer"
                        >${tag}</button>
                      `)}
                    </div>
                  ` : ""}

                    <div class="flex gap-1">
                      <a href="${editUrl}" data-turbo-frame="modal" class="btn btn-ghost btn-sm text-primary px-1">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-6">
                          <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
                        </svg>
                      </a>
                    </div>
                  </div>
                </div>
              </div>
            `
          },
          empty({ query }, { html }) {
            return html`
              <div class="col-span-3 text-center py-10 text-gray-500">
                Nenhuma nota encontrada para "<strong>${query}</strong>".
              </div>
            `
          },
        },
      }),

      pagination({
        container: "#ais-pagination",
        padding: 2,
        cssClasses: {
          root: "join flex justify-center my-6",
          list: "flex",
          item: "join-item btn",
          link: "join-item",
          selectedItem: "join-item btn-active",
          disabledItem: "join-item",
          previousPageItem: "",
          nextPageItem: "",
        },
        templates: {
          previous({ cssClasses }, { html }) {
            return html`← Anterior`
          },
          next({ cssClasses }, { html }) {
            return html`Próxima →`
          },
          first({ cssClasses }, { html }) {
            return html`«`
          },
          last({ cssClasses }, { html }) {
            return html`»`
          },
        },
      }),
    ])

    search.start()
    this.search = search
  }

  disconnect() {
    if (this.search) {
      this.search.dispose()
    }
  }
}
