import { getDiffsMetadata, getDiffsBatch } from 'test_helpers/fixtures';
import { withValues } from 'test_helpers/utils/obj';

export default (server) => {
  server.get('/:namespace/:project/-/merge_requests/:mrid/diffs_metadata.json', () => {
    return getDiffsMetadata();
  });

  server.get('/:namespace/:project/-/merge_requests/:mrid/diffs_batch.json', () => {
    const { pagination, ...result } = getDiffsBatch();

    return {
      ...result,
      pagination: withValues(pagination, {
        current_page: null,
        next_page: null,
        total_pages: 1,
        next_page_href: null,
      }),
    };
  });
};
