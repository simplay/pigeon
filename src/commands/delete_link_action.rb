# Delete a discription link by providing a substring of the target identifier.
#
# @example
#   Given the identifier mc_foo, delete it from the description:
#     !ddl foo
class DeleteLinkAction < WithArgumentsAction

  # @param msg [Array] first of this array should correspond to the item
  #   label that should be deleted.
  def run(msg)
    id = DescriptionLinkStore.find_all_including_key(msg[0], true).first
    DescriptionLinkStore.delete(id.first)
  end
end
