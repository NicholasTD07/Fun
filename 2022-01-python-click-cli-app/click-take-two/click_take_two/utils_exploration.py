import click

@click.group()
def cli():
    pass


@cli.command()
def clear():
    click.clear()


@cli.command()
def styled_echo():
    click.echo(click.style('Hello World!', fg='green'))

    click.secho('Some more text', bg='blue', fg='white')
    click.secho('ATTENTION', blink=True, bold=True)


@cli.command()
def get_commit_message():
    MARKER = '# Everything below is ignored\n'
    message = click.edit('\n\n' + MARKER)
    if message is not None:
        print(message.split(MARKER, 1)[0].rstrip('\n'))


@cli.command()
def progressbar():
    import time

    numbers = [ i for i in range(0, 100) ]
    with click.progressbar(numbers, label='Updating') as bar:
        for number in bar:
            time.sleep(0.1)

    # with click.progressbar([1, 2, 3]) as bar:
    #     for x in bar:
    #         print(f"sleep({x})...")
    #         time.sleep(x)


if __name__ == '__main__':
    cli()
