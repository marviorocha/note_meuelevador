require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @author = Author.create!(name: "Test Author")
    @category = Category.create!(name: "Test Category")
    @subcategory = Subcategory.create!(name: "Test Subcategory", category: @category)
    @note = Note.create!(
      author: @author,
      subcategory: @subcategory,
      content: "Initial content",
      status: :revisar
    )
  end

  test "should get index" do
    get notes_url
    assert_response :success
  end

  test "should get edit" do
    get edit_note_url(@note)
    assert_response :success
  end

  test "should update note" do
    patch note_url(@note), params: { note: { content: "Updated content" } }
    assert_redirected_to notes_path
    @note.reload
    assert_equal "Updated content", @note.content
  end

  test "should destroy note" do
    assert_difference("Note.count", -1) do
      delete note_url(@note)
    end
    assert_redirected_to notes_path
  end
end
