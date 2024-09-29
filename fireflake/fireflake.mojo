from time import time
from python import Python
from os import Atomic
from sys.info import os_is_linux

fn time_ms() raises -> Int64:
    """
    Get the time since Unix epoch in milliseconds.

    Currently, we're relying on Python to get the unix epoch time because Mojo
    does not have stable support for it in the stdlib.

    Returns:
        The time in milliseconds.
    """
    @parameter
    if os_is_linux():
        # https://discord.com/channels/1087530497313357884/1289527627807330365/1289621768205635658
        time_ns = Int64(time._gettime_as_nsec_unix(11))
    else:
        var time = Python.import_module("time")
        time_ns = Int64(time.time_ns())

    var time_ms = time_ns // 1_000_000
    return time_ms

fn since_epoch[epoch: Int64]() raises -> Int64:
    """
    Get the time since a given epoch.

    Default epoch: Saturday, 28 September 2024 11:28:50.324.

    Returns:
        Time in milliseconds.
    """

    return time_ms() - epoch

struct Fireflake[
    node_bits_count: Int64 = 12,
    sequence_bits_count: Int64 = 10,
    epoch: Int64 = 1727522930324,
]:
    """
    Fireflake id generator. Create an instance of this struct only once and call
    it's `generate()` method as many times as you wish. The API is thread-safe.

    Default layout (64-bit signed integer):

    - sign bit - positive or negative, not relevant for id generator.
    - time - a unix timestamp (ms) since the `Self.epoch`.
    - node - a conceptual partition - a shard, a vm, node in a cluster, etc.
    - sequence - an auto-incrementing id, that's thread safe to use.

    ```
        1    |  41  |  12  |    10
    sign bit | time | node | sequence
    ```
    """

    var current_sequence: Atomic[DType.int64]

    fn __init__(inout self) raises:
        constrained[(Self.node_bits_count >= 0)
                and (Self.sequence_bits_count >= 0)
                and (Self.node_bits_count + Self.sequence_bits_count == 64-1-41),
            "Invalid number of bits count for node and sequence. Must be 22 exactly."]()

        constrained[Self.epoch > 0, "Epoch must be greater than 0."]()

        self.current_sequence = Atomic[DType.int64](0)

    fn generate_next_sequence(inout self) -> Int64:
        """
        Generates the next number in the sequence. Uses atomics to ensure that
        it's thread safe. Once the sequence reaches the end of the max limit for
        the number of bits allowed for sequences, it'll rotate back to 0.

        Returns:
            The next number in the sequence.
        """
        # TODO: `Atomic.fetch_add` is wrongly taking `inout self`, it's a bug
        # and will most likely be fixed in a newer release of mojo.
        # https://discord.com/channels/1087530497313357884/1289598980845731893
        result = self.current_sequence.fetch_add(1)
        result = result & ((1 << Self.sequence_bits_count) - 1)
        return result

    fn generate(inout self) raises -> Int64:
        """
        Generate a new id, taking both the node and sequence bits into account.
        The generated id is safe to store in a 64-bit integer.

        Returns:

            The next id.
        """
        timestamp = since_epoch[Self.epoch]()
        next_sequence = self.generate_next_sequence()

        result = timestamp << (Self.node_bits_count + Self.sequence_bits_count)
        result = result | (Self.node_bits_count << Self.sequence_bits_count)
        result = result | next_sequence

        return result

    fn generate(inout self, owned number: Int64) raises -> Int64:
        """
        Generate a new id, where the given `number` will replace the
        `Self.node_bits_count + Self.sequence_bits_count` bits in the generated
        id.

        Use this method when you want to provide a custom node + sequence bits
        part. The number may be hash of one or more of your data: such as the
        table name, the string data that you're generating id for, etc or it can
        be a plain number of your choosing that you may have generated from
        somewhere else or holds some kind of special meaning.

        If the number contains bits in the range greater than what's specified
        above (node + sequence bits count), it'll be clipped. In this case, the
        default layout will look like the following:

        ```
            1    |  41  |   22
        sign bit | time | number
        ```

        The generated id is safe to store in a 64-bit integer.

        Returns:

            The next id.
        """
        timestamp = since_epoch[Self.epoch]()

        number_bits = Self.node_bits_count + Self.sequence_bits_count

        number &= (1 << number_bits) - 1

        result = timestamp << number_bits
        result = result | number

        return result
