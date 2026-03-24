#include <cstdint>
#include <cstdio>
#include <vector>
#include <thread>
#include <mutex>
#include <atomic>
#include <random>
#include <cstring>

#include "lib.h"
#include "xrsr.h"

std::mutex output_mutex;

bool check_12_eye(uint64_t world_seed, int chunk_x, int chunk_z)
{
    XRSR128 rng;

    xrsr128_setFeatureSeed(&rng, world_seed,
        chunk_x << 4,
        chunk_z << 4,
        19, 4);

    skip_cpu(&rng, 0, 0);

    for (int i = 0; i < 12; i++) {
        if (xrsr_long(&rng) < 16602070326045573120ULL) {
            return false;
        }
    }

    return true;
}

void worker(
    uint64_t structure_seed,
    int start_chunk_x,
    int start_chunk_z,
    int portal_chunk_x,
    int portal_chunk_z,
    uint64_t start_hi,
    uint64_t end_hi)
{
    for (uint64_t hi = start_hi; hi < end_hi; hi++) {
        uint64_t world_seed = (hi << 48) | structure_seed;

        if (check_12_eye(world_seed, portal_chunk_x, portal_chunk_z)) {
            std::lock_guard<std::mutex> lock(output_mutex);
            printf("Seed: %lld Start: %d %d Portal: %d %d\n",
                   (long long)world_seed,
                   start_chunk_x,
                   start_chunk_z,
                   portal_chunk_x << 4,
                   portal_chunk_z << 4);
        }
    }
}

int main()
{
    const uint32_t thread_count = std::thread::hardware_concurrency();

    std::vector<Layout> layouts(1 << 16);

    uint64_t structure_seed_start = 0;
    uint64_t structure_seed_end   = 1 << 16;

    for (uint64_t ss = structure_seed_start; ss < structure_seed_end; ss++)
    {
        uint32_t count = generate_layouts(
            ss << 16,
            (ss << 16) + (1 << 16),
            false,
            layouts.data(),
            layouts.size());

        for (uint32_t i = 0; i < count; i++)
        {
            Layout &layout = layouts[i];

            uint64_t total_hi = 1ULL << 16;
            uint64_t chunk = total_hi / thread_count;

            std::vector<std::thread> threads;

            for (uint32_t t = 0; t < thread_count; t++) {
                uint64_t start = t * chunk;
                uint64_t end = (t == thread_count - 1) ? total_hi : start + chunk;

                threads.emplace_back(worker,
                    layout.structure_seed,
                    layout.start_chunk_x,
                    layout.start_chunk_z,
                    layout.portal_chunk_x,
                    layout.portal_chunk_z,
                    start,
                    end);
            }

            for (auto &th : threads)
                th.join();
        }
    }

    return 0;
}
